semantic_versions = YAML.load(File.read(File.join(__dir__, '..', '..', 'fixtures', 'semantic_versions.yaml'))).deep_symbolize_keys
operators = semantic_versions[:operators] + semantic_versions[:operators].map{ |o| "#{o} " unless o.empty? }.compact

RSpec.describe Sourcerer::Version do
  before do
    class FooVersion
      include Sourcerer::Version
    end

    @version = FooVersion.allocate
  end

  describe '#find_matching_version' do
    before do
      allow(@version).to receive(:find_matching_semantic_version).and_return :semantic_version
    end

    after do
      allow(@version).to receive(:find_matching_semantic_version).and_call_original
    end

    it "should detect semantic versions (x#{semantic_versions[:versions].length}) w/ operators (x#{operators.length})" do
      semantic_versions[:versions].each do |sv|
        operators.each do |o|
          version = "#{o}#{sv[:version]}"
          semantic_version = @version.find_matching_version version: version, versions_array: []

          expect(@version).to have_received(:find_matching_semantic_version).with({ criteria: version, versions_array: [] })
          expect(semantic_version).to eq :semantic_version
        end
      end

      expect(@version).to have_received(:find_matching_semantic_version).exactly(semantic_versions[:versions].length * operators.length)
    end

    it 'should detect exact versions/tags' do
      [
        Semantic::Version.new('1.2.3'),
        :latest,
        'branch',
        'f7ae716',
        'f7ae7164f8d725ccbe0fa2b5c4c2699824c787e5',
        'tag'
      ].each do |v|
        version = @version.find_matching_version version: v, versions_array: [v]

        expect(@version).to_not have_received(:find_matching_semantic_version)
        expect(version).to eq v
      end
    end

    it 'should return nil if no version found' do
      version = @version.find_matching_version version: 'foo', versions_array: ['bar']

      expect(@version).to_not have_received(:find_matching_semantic_version)
      expect(version).to be_nil
    end
  end

  describe '#find_matching_semantic_version' do
    before do
      allow(@version).to receive(:get_valid_semantic_version)

      @filter_versions_calls = []
      allow(@version).to receive(:filter_versions) do |args|
        @filter_versions_calls << args[:operator]
      end.and_return [Semantic::Version.new('1.2.3'), Semantic::Version.new('3.2.1')]
    end

    after do
      allow(@version).to receive(:get_valid_semantic_version).and_call_original
      allow(@version).to receive(:filter_versions).and_call_original
    end

    it "should filter with proper operators (x#{operators.length})" do
      operators.each do |o|
        matching_semantic_version = @version.send :find_matching_semantic_version, criteria: "#{o}1.2.3", versions_array: []

        case
        when o.empty?         # no operator
          expect(@filter_versions_calls).to eq ['==']
        when o.include?('~')  # ~, ~> (pessimistic) operators, or .x placeholders
          expect(@filter_versions_calls).to eq ['>=', '<']
        else                  # >=, >, <=, < operator operators
          expect(@filter_versions_calls).to eq [o.strip]
        end

        expect(matching_semantic_version).to be_a Semantic::Version
        expect(matching_semantic_version.to_s).to eq '3.2.1'

        # clear method calls array
        @filter_versions_calls = []
      end

      expect(@version).to have_received(:filter_versions).at_least(operators.length).times
    end
  end

  describe '#get_valid_semantic_version' do
    before do
      allow(@version).to receive(:assemble_semantic_version)
    end

    after do
      allow(@version).to receive(:assemble_semantic_version).and_call_original
    end

    context 'when increment is true' do
      semantic_versions[:versions].each do |sv|
        operators.each do |o|
          it "should accept #{o}#{sv[:version]} and return #{sv[:full_incremented]}" do
            criteria = "#{o}#{sv[:version]}"
            complete_version_array = sv[:full_incremented].match(Sourcerer::SEMANTIC_VERSION_ARTIFACT_REGEX).to_a
            complete_version_array[0] = criteria

            @version.send :get_valid_semantic_version, criteria: criteria, increment: true

            expect(@version).to have_received(:assemble_semantic_version).with({ criteria_array: complete_version_array })
          end
        end
      end
    end

    context 'when increment is false' do
      semantic_versions[:versions].each do |sv|
        operators.each do |o|
          it "should accept #{o}#{sv[:version]} and return #{sv[:full]}" do
            criteria = "#{o}#{sv[:version]}"
            complete_version_array = sv[:full].match(Sourcerer::SEMANTIC_VERSION_ARTIFACT_REGEX).to_a
            complete_version_array[0] = criteria

            @version.send :get_valid_semantic_version, criteria: criteria, increment: false

            expect(@version).to have_received(:assemble_semantic_version).with({ criteria_array: complete_version_array })
          end
        end
      end
    end
  end
end
