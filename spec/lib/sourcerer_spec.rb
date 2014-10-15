describe Sourcerer do
  before do
    allow_any_instance_of(Sourcerer).to receive(:init_source_type)
  end

  after do
    allow_any_instance_of(Sourcerer).to receive(:init_source_type).and_call_original
  end

  it 'should call #create_source_type' do
    sourcerer = Sourcerer.new 'spec/fixtures/source.dir'
    expect(sourcerer).to have_received(:init_source_type).with :dir
  end

  describe '.destination' do
    context 'when no custom destination is passed' do
      it 'should return a valid directory' do
        sourcerer = Sourcerer.new 'spec/fixtures/source.dir'
        expect(Dir.exists?(sourcerer.destination)).to be true
      end
    end

    context 'when a custom destination is passed' do
      before do
        FileUtils.mkdir_p './tmp/foo_destination'
      end

      after do
        FileUtils.rm_r './tmp/foo_destination'
      end

      it 'should return a valid directory' do
        sourcerer = Sourcerer.new 'spec/fixtures/source.dir', './tmp/foo_destination'
        expect(Dir.exists?(sourcerer.destination)).to be true
      end
    end
  end

  describe '#files' do
    it 'should pass arguments to the source type' do
      sourcerer = Sourcerer.new 'spec/fixtures/source.dir'
      files_spy = spy('files')
      sourcerer.var :type, files_spy

      sourcerer.files :all, false

      expect(files_spy).to have_received(:files).with(:all, false)
    end
  end

  # TEST FOR ALL TYPES HERE
  #
  describe '#detect_type' do
    context 'with a dir' do
      it 'should detect local relative paths' do
        sourcerer = Sourcerer.new 'spec/fixtures/source.dir'
        expect(sourcerer.send(:detect_type)).to eq :dir
      end

      it 'should detect local absolute paths' do
        sourcerer = Sourcerer.new File.expand_path('spec/fixtures/source.dir')
        expect(sourcerer.send(:detect_type)).to eq :dir
      end
    end

    context 'with a git repo' do
      it 'should detect local git repos' do
        sourcerer = Sourcerer.new 'spec/fixtures/source.git'
        expect(sourcerer.send(:detect_type)).to eq :git
      end

      it 'should detect remote git repos' do
        sourcerer = Sourcerer.new 'https://github.com/brewster1134/sourcerer.git'
        expect(sourcerer.send(:detect_type)).to eq :git
      end

      it 'should detect github shorthand repos' do
        sourcerer = Sourcerer.new 'brewster1134/sourcerer'
        expect(sourcerer.send(:detect_type)).to eq :git
      end
    end

    context 'with a zip file' do
      it 'should detect local zip files' do
        sourcerer = Sourcerer.new 'spec/fixtures/source.zip'
        expect(sourcerer.send(:detect_type)).to eq :zip
      end

      it 'should detect remote zip files' do
        sourcerer = Sourcerer.new 'https://github.com/brewster1134/sourcerer/archive/master.zip'
        expect(sourcerer.send(:detect_type)).to eq :zip
      end
    end
  end
end
