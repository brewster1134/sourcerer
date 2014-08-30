describe Sourcerer do

  # TEST FOR ALL TYPES HERE
  #
  describe '#detect_type' do
    context 'with a dir' do
      it 'should detect local relative paths' do
        @sourcerer = Sourcerer.new 'spec/fixtures/source_dir'
        # expect(@sourcerer.source).to eq File.expand_path('spec/fixtures/source_dir')
        expect(@sourcerer.type).to eq :dir
      end

      it 'should detect local absolute paths' do
        @sourcerer = Sourcerer.new File.expand_path('spec/fixtures/source_dir')
        expect(@sourcerer.type).to eq :dir
      end
    end

    context 'with a git repo' do
      it 'should detect local git repos' do
        @sourcerer = Sourcerer.new 'spec/fixtures/source.git'
        expect(@sourcerer.type).to eq :git
      end

      it 'should detect remote git repos' do
        @sourcerer = Sourcerer.new 'https://github.com/brewster1134/sourcerer.git'
        expect(@sourcerer.type).to eq :git
      end

      it 'should detect github shorthand repos' do
        @sourcerer = Sourcerer.new 'brewster1134/sourcerer'
        # expect(@sourcerer.source).to eq 'https://github.com/brewster1134/sourcerer.git'
        expect(@sourcerer.type).to eq :git
      end
    end

    context 'with a zip file' do
      it 'should detect local zip files' do
        @sourcerer = Sourcerer.new 'spec/fixtures/source.zip'
        # expect(@sourcerer.source).to eq File.expand_path('spec/fixtures/source.zip')
        expect(@sourcerer.type).to eq :zip
      end

      it 'should detect remote zip files' do
        @sourcerer = Sourcerer.new 'https://github.com/brewster1134/sourcerer/archive/master.zip'
        expect(@sourcerer.type).to eq :zip
      end
    end
  end

  describe '#tmp_dir' do
    it 'should return a valid directory' do
      @sourcerer = Sourcerer.new 'foo_dir'
      expect(Dir.exists?(@sourcerer.tmp_dir)).to be true
    end
  end

  describe '#dest_dir' do
    it 'should return a valid directory' do
      @sourcerer = Sourcerer.new 'foo_dir'
      expect(Dir.exists?(@sourcerer.dest_dir)).to be true
    end
  end

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
  @test_sources = [
    'sourec_dir',
    'source.git',
    'source.zip'
  ]

  @test_sources.each do |test_source|
    describe test_source do
      before do
        @sourcerer = Sourcerer.new test_source
      end

      describe '#files' do
        it 'should list all files' do
          expect(@sourcerer.files).to match_array([
            'foo/file.foo',
            'bar/file.bar',
            '.hidden_foo'
          ])
        end

        it 'should list globbed files' do
          expect(@sourcerer.files('*.foo')).to match_array ['foo/file.foo']
        end
      end

      describe '#copy_to' do
        it 'should copy files to a tmp dir' do
          expect(File.exists?(File.join(@sourcerer.tmp_dir, 'foo/file.foo'))).to be true
          expect(File.exists?(File.join(@sourcerer.tmp_dir, 'bar/file.bar'))).to be true
          expect(File.exists?(File.join(@sourcerer.tmp_dir, '.hidden_foo'))).to be true
        end
      end
    end
  end
end
