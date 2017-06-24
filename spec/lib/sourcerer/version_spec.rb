semantic_versions = YAML.load(File.read(File.join(__dir__, '..', '..', 'fixtures', 'semantic_versions.yaml'))).deep_symbolize_keys
operators = Sourcerer::SEMANTIC_VERSION_OPERATORS + Sourcerer::SEMANTIC_VERSION_OPERATORS.map{ |o| "#{o} " unless o.empty? }.compact

RSpec.describe Sourcerer::Version do
  before do
    class FooVersion
      include Sourcerer::Version
      def latest; end
    end
  end

  describe '#find_matching_version' do
    before do
      @version = FooVersion.allocate

      allow(@version).to receive(:latest).and_return 'latest version'
      allow(@version).to receive(:find_matching_semantic_version).and_return 'semantic version'
    end

    it 'should handle :latest' do
      matching_version = @version.find_matching_version version: :latest, versions_array: ['latest']

      expect(@version).to have_received(:latest)
      expect(@version).to_not have_received(:find_matching_semantic_version)
      expect(matching_version).to eq 'latest version'
    end

    it "should detect semantic version criteria" do
      semantic_versions[:versions].each do |sv|
        operators.each do |o|
          criteria = "#{o}#{sv[:version]}"
          matching_version = @version.find_matching_version version: criteria, versions_array: []

          expect(@version).to_not have_received(:latest)
          expect(@version).to have_received(:find_matching_semantic_version).with({ criteria: criteria, versions_array: [] })
          expect(matching_version).to eq 'semantic version'
        end
      end

      expect(@version).to have_received(:find_matching_semantic_version).exactly(semantic_versions[:versions].length * operators.length)
    end

    it 'should detect exact versions/tags' do
      [
        'branch',
        'f7ae716',
        'f7ae7164f8d725ccbe0fa2b5c4c2699824c787e5',
        'tag'
      ].each do |v|
        matching_version = @version.find_matching_version version: v, versions_array: [v]

        expect(@version).to_not have_received(:latest)
        expect(@version).to_not have_received(:find_matching_semantic_version)
        expect(matching_version).to eq v.to_s
      end
    end

    it 'should return the latest version as a last resort' do
      matching_version = @version.find_matching_version version: 'foo', versions_array: ['bar']

      expect(@version).to have_received(:latest)
      expect(@version).to_not have_received(:find_matching_semantic_version)
      expect(matching_version).to eq 'latest version'
    end
  end

  describe '#find_matching_semantic_version' do
    before do
      @version = FooVersion.allocate
      allow(@version).to receive(:get_valid_semantic_version)

      @filter_versions_calls = []
      allow(@version).to receive(:filter_versions) do |args|
        @filter_versions_calls << args[:operator]
      end.and_return [Semantic::Version.new('1.2.3'), Semantic::Version.new('3.2.1')]
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
      @version = FooVersion.allocate
      allow(@version).to receive(:assemble_semantic_version)
    end

    # after do
    #   allow(@version).to receive(:assemble_semantic_version).and_call_original
    # end

    context 'when increment is true' do
      it 'should increment version' do
        # it "should accept #{o}#{sv[:version]} and return #{sv[:full_incremented]}" do
        semantic_versions[:versions].each do |sv|
          operators.each do |o|
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
      it 'not increment version' do
        semantic_versions[:versions].each do |sv|
          operators.each do |o|
            # it "should accept #{o}#{sv[:version]} and return #{sv[:full]}" do
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

  describe '#assemble_semantic_version' do
    it 'should return a proper version string from criteria array' do
      @version = FooVersion.allocate

      semantic_versions[:versions].each do |sv|
        criteria_array = sv[:version].match(Sourcerer::SEMANTIC_VERSION_ARTIFACT_REGEX).to_a
        expect(@version.send(:assemble_semantic_version, criteria_array: criteria_array)).to eq sv[:full]
      end
    end
  end
end
