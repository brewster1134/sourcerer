require 'active_support/core_ext/string/inflections'

describe Sourcerer::SourceType do
  # Test common behavior for all supported source types
  #
  # All sources must have the following structure
  #
  # |_ bar
  # | |_ file.bar
  # |_ foo
  # | |_ file.foo
  # |_ .hidden_foo
  #
  describe 'supported source types' do
    source_types = [
      :dir,
      :git,
      :zip
    ]

    source_types.each do |source_type|
      describe source_type do
        before do
          require "sourcerer/source_types/#{source_type}"
          dbl = double({
            source: "spec/fixtures/source.#{source_type}",
            destination: ::Dir.mktmpdir,
            interpolation_data: {}
          })

          @source_type = "Sourcerer::SourceType::#{source_type.to_s.classify}".constantize.new dbl
        end

        it 'should inherit from SourceType' do
          expect(@source_type.class.superclass).to eq Sourcerer::SourceType
        end

        it 'should copy files to a tmp dir' do
          expect(File.exists?(File.join(@source_type.destination, 'foo/file.foo'))).to be true
          expect(File.exists?(File.join(@source_type.destination, 'bar/file.bar'))).to be true
          expect(File.exists?(File.join(@source_type.destination, '.hidden_foo'))).to be true
        end

        describe '#files' do
          it 'should list all files' do
            expect(@source_type.files(:all, true)).to match_array([
              'foo/file.foo',
              'bar/file.bar',
              '.hidden_foo'
            ])
          end

          it 'should list only matching files' do
            expect(@source_type.files('**/*.foo', true)).to match_array [
              'foo/file.foo'
            ]
          end
        end
      end
    end
  end
end
