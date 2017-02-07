RSpec.describe Sourcerer::Version do
  before do
    @semantic_versions = YAML.load(File.join(__dir__, '..', '..', 'fixtures', 'semantic_versions_list.txt'))

    class FooVersion
      include Sourcerer::Version
    end
  end

  describe '#find_matching_version' do
    before do
      @version = FooVersion.allocate

      allow(@version).to receive(:find_matching_semantic_version).and_return '1.2.3'
    end

    # wildcard semantic versions
    [
      '<= 1.2.3',
      '<=1.2.3-beta.45',
      '<=1.2.3-beta.4.5-rev.6.7.8',
      '> 1.2.3',
      '>=1.2.3',
      '~> 1.2.3',
      '~> 1.2',
      '~> 1',
      '~>1.2.3',
      '~>1.2',
      '~>1',
      '~1.2.3',
      '~1.2',
      '~1',
      '1.2.x',
      '1.2',
      '1.x',
      '1'
    ].each do |sv|
      it "should detect semantic version wildcard: #{sv}" do
        version = @version.find_matching_version version: sv, versions_array: [sv]
        expect(@version).to have_received(:find_matching_semantic_version).with({ criteria: sv, versions_array: [sv] })
        expect(version).to eq '1.2.3'
      end
    end

    # semantic versions
    [
      Semantic::Version.new('1.2.3-beta.45'),
      Semantic::Version.new('1.2.3'),
    ].each do |sv|
      it "should detect exact semantic version: #{sv}" do
        version = @version.find_matching_version version: sv, versions_array: [sv]
        expect(@version).to_not have_received(:find_matching_semantic_version)
        expect(version).to eq sv
      end
    end

    # non-semantic versions
    [
      :latest,
      'branch',
      'f7ae716',
      'f7ae7164f8d725ccbe0fa2b5c4c2699824c787e5',
      'tag'
    ].each do |sv|
      it "should detect non-semantic versions: #{sv}" do
        version = @version.find_matching_version version: sv, versions_array: [sv]
        expect(@version).to_not have_received(:find_matching_semantic_version)
        expect(version).to eq sv
      end
    end

    it 'should return nil if no version found' do
      version = @version.find_matching_version version: 'foo', versions_array: ['bar']
      expect(version).to be_nil
    end
  end

  describe '#find_matching_semantic_version' do
    before do
      @version = FooVersion.allocate

      @filter_versions_calls = []
      allow(@version).to receive(:filter_versions) do |args|
        @filter_versions_calls << args
      end.and_return [1, 2]
    end

    [
      # no operator
      [ '1',                            '==', '1.0.0' ],
      [ '1.2',                          '==', '1.2.0' ],
      [ '1.2.3',                        '==', '1.2.3' ],
      [ '1.2.3-alpha',                  '==', '1.2.3-alpha' ],
      [ '1.2.3-alpha.4',                '==', '1.2.3-alpha.4.0.0' ],
      [ '1.2.3-alpha.4.5',              '==', '1.2.3-alpha.4.5.0' ],
      [ '1.2.3-alpha.4.5.6',            '==', '1.2.3-alpha.4.5.6' ],
      [ '1.2.3-alpha.4.5.6-rev',        '==', '1.2.3-alpha.4.5.6-rev' ],

      # pessimistic operator
      [ '~1',                     '>=', '1.0.0',                  '<',  '2.0.0' ],
      [ '~1.2',                   '>=', '1.2.0',                  '<',  '2.0.0' ],
      [ '~1.2.3',                 '>=', '1.2.3',                  '<',  '1.3.0' ],
      [ '~1.2.3-alpha',           '>=', '1.2.3-alpha.0.0.0',      '<',  '1.2.3' ],
      [ '~1.2.3-alpha.4',         '>=', '1.2.3-alpha.4.0.0',      '<',  '1.2.3-alpha.5.0.0' ],
      [ '~1.2.3-alpha.4.5',       '>=', '1.2.3-alpha.4.5.0',      '<',  '1.2.3-alpha.5.0.0' ],
      [ '~1.2.3-alpha.4.5.6',     '>=', '1.2.3-alpha.4.5.6',      '<',  '1.2.3-alpha.4.6.0' ],
      [ '~1.2.3-alpha.4.5.6-rev', '>=', '1.2.3-alpha.4.5.6-rev',  '<',  '1.2.3-alpha.4.6.0-rev' ],

      # x placeholder
      [ '1.x',                '>=', '1.0.0',              '<',  '2.0.0' ],
      [ '1.2.x',              '>=', '1.2.0',              '<',  '1.3.0' ],
      [ '1.2.3-alpha.x',      '>=', '1.2.3-alpha.0.0.0',  '<',  '1.2.3' ],
      [ '1.2.3-alpha.4.x',    '>=', '1.2.3-alpha.4.0.0',  '<',  '1.2.3-alpha.5.0.0' ],
      [ '1.2.3-alpha.4.5.x',  '>=', '1.2.3-alpha.4.5.0',  '<',  '1.2.3-alpha.4.6.0' ],

      # >=
      [ '>=1',                  '>=', '1.0.0' ],
      [ '>=1.2',                '>=', '1.2.0' ],
      [ '>=1.2.3',              '>=', '1.2.3' ],
      [ '>=1.2.3-alpha',        '>=', '1.2.3-alpha.0.0.0' ],
      [ '>=1.2.3-alpha.4',      '>=', '1.2.3-alpha.4.0.0' ],
      [ '>=1.2.3-alpha.4.5',    '>=', '1.2.3-alpha.4.5.0' ],
      [ '>=1.2.3-alpha.4.5.6',  '>=', '1.2.3-alpha.4.5.6' ],

      # >
      [ '>1',                 '>',  '1.0.0' ],
      [ '>1.2',               '>',  '1.2.0' ],
      [ '>1.2.3',             '>',  '1.2.3' ],
      [ '>1.2.3-alpha',       '>',  '1.2.3-alpha.0.0.0' ],
      [ '>1.2.3-alpha.4',     '>',  '1.2.3-alpha.4.0.0' ],
      [ '>1.2.3-alpha.4.5',   '>',  '1.2.3-alpha.4.5.0' ],
      [ '>1.2.3-alpha.4.5.6', '>',  '1.2.3-alpha.4.5.6' ],

      # <=
      [ '<=1',                  '<=', '1.0.0' ],
      [ '<=1.2',                '<=', '1.2.0' ],
      [ '<=1.2.3',              '<=', '1.2.3' ],
      [ '<=1.2.3-alpha',        '<=', '1.2.3-alpha.0.0.0' ],
      [ '<=1.2.3-alpha.4',      '<=', '1.2.3-alpha.4.0.0' ],
      [ '<=1.2.3-alpha.4.5',    '<=', '1.2.3-alpha.4.5.0' ],
      [ '<=1.2.3-alpha.4.5.6',  '<=', '1.2.3-alpha.4.5.6' ],

      # <
      [ '<1',                 '<',  '1.0.0' ],
      [ '<1.2',               '<',  '1.2.0' ],
      [ '<1.2.3',             '<',  '1.2.3' ],
      [ '<1.2.3-alpha',       '<',  '1.2.3-alpha.0.0.0' ],
      [ '<1.2.3-alpha.4',     '<',  '1.2.3-alpha.4.0.0' ],
      [ '<1.2.3-alpha.4.5',   '<',  '1.2.3-alpha.4.5.0' ],
      [ '<1.2.3-alpha.4.5.6', '<',  '1.2.3-alpha.4.5.6' ]

    ].each do |cov| # criteria, operator, version
      it "should handle `#{cov[0]}`" do
        criteria = cov.shift

        @version.send :find_matching_semantic_version, criteria: criteria, versions_array: [1, 2]

        cov_args = []
        until cov.empty?
          args = cov.shift(2)
          cov_args << {
            versions_array: [1, 2],
            operator: args[0],
            version: args[1]
          }
        end

        expect(@filter_versions_calls).to eq cov_args
      end
    end
  end
end
