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
    @test_sources = [
      'dir',
      'git',
      'zip'
    ]

    @test_sources.each do |test_source|
      describe test_source do
        before do
          allow(Sourcerer).to receive(:source).and_return "spec/fixtures/source.#{test_source}"
          allow(Sourcerer).to receive(:destination).and_return ::Dir.mktmpdir

          require "sourcerer/source_types/#{test_source}"
          @source_type = Sourcerer.instance_var(:type).new
          @basepath = Pathname.new(@source_type.destination)
        end

        after do
          allow(Sourcerer).to receive(:source).and_call_original
          allow(Sourcerer).to receive(:destination).and_call_original
        end

        it 'should set the type' do
          expect(@source_type.class.superclass).to eq Sourcerer::SourceType
        end

        it 'should copy files to a tmp dir' do
          expect(File.exists?(File.join(@source_type.destination, 'foo/file.foo'))).to be true
          expect(File.exists?(File.join(@source_type.destination, 'bar/file.bar'))).to be true
          expect(File.exists?(File.join(@source_type.destination, '.hidden_foo'))).to be true
        end

        describe '#files' do
          it 'should list all files' do
            relative_files = @source_type.files.map do |file|
              Pathname.new(file).relative_path_from(@basepath).to_s
            end

            expect(relative_files).to match_array([
              'foo/file.foo',
              'bar/file.bar',
              '.hidden_foo'
            ])
          end

          it 'should list only matching files' do
            relative_files = @source_type.files('**/*.foo').map do |file|
              Pathname.new(file).relative_path_from(@basepath).to_s
            end

            expect(relative_files).to match_array [
              'foo/file.foo'
            ]
          end
        end
      end
    end
  end
end
