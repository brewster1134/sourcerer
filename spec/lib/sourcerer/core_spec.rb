describe Sourcerer::Core do
  before do
    @core_instance = Sourcerer::Core.allocate
    @error_instance = Sourcerer::Error.allocate
  end

  describe '#initialize' do
    before do
      class Foo
        def initialize source, destination, options
        end
      end

      class Bar
      end

      allow(@core_instance).to receive(:get_type_source).and_return type: :foo, source: 'source'
      allow(@core_instance).to receive(:get_type_class).and_return Foo
      allow(Foo).to receive(:new).and_return Bar.new

      @core = @core_instance.send :initialize, 'source', 'destination', {}
    end

    after do
      allow(@core_instance).to receive(:get_type_source).and_call_original
      allow(@core_instance).to receive(:get_type_class).and_call_original
      allow(File).to receive(:extname).and_call_original
    end

    it 'should initialize the proper source type' do
      expect(@core_instance).to have_received(:get_type_source).with('source').ordered
      expect(@core_instance).to have_received(:get_type_class).with(:foo).ordered
      expect(Foo).to have_received(:new).with('source', File.expand_path('destination'), {}).ordered
    end

    it 'should return a source type instance' do
      expect(@core).to be_a Bar
    end
  end

  describe '#get_type_source' do
    it 'should detect various sources' do
      sources = [{
        source_type: :dir,
        source_in: 'spec/fixtures/source.dir',
        source_out: File.expand_path('spec/fixtures/source.dir')
      }, {
        source_type: :dir,
        source_in: 'spec/fixtures/source.git',
        source_out: File.expand_path('spec/fixtures/source.git')
      }, {
        source_type: :git,
        source_in: 'brewster1134/sourcerer',
        source_out: 'brewster1134/sourcerer'
      }, {
        source_type: :git,
        source_in: 'git@github.com:brewster1134/sourcerer.git',
        source_out: 'git@github.com:brewster1134/sourcerer.git'
      }, {
        source_type: :git,
        source_in: 'https://github.com/brewster1134/sourcerer.git',
        source_out: 'https://github.com/brewster1134/sourcerer.git'
      }, {
        source_type: :git,
        source_in: 'https://github.com/brewster1134/sourcerer',
        source_out: 'https://github.com/brewster1134/sourcerer'
      }, {
        source_type: :zip,
        source_in: 'spec/fixtures/source.zip',
        source_out: File.expand_path('spec/fixtures/source.zip')
      }, {
        source_type: :zip,
        source_in: 'https://github.com/brewster1134/sourcerer/archive/master.zip',
        source_out: 'https://github.com/brewster1134/sourcerer/archive/master.zip'
      }]

      sources.each do |source|
        expect(@core_instance.get_type_source(source[:source_in])).to eq(
          type: source[:source_type],
          source: source[:source_out]
        )
      end
    end

    it 'should raise an error if not source could be determined' do
      allow(File).to receive(:extname).and_return nil
      allow(Sourcerer::Error).to receive(:new).and_return @error_instance

      expect{ @core_instance.get_type_source('foo') }.to raise_error @error_instance

      allow(File).to receive(:extname).and_call_original
      allow(Sourcerer::Error).to receive(:new).and_call_original
    end
  end

  describe '#get_type_class' do
    it 'should initialize a source type from a string' do
      class Sourcerer::SourceType::Foo < Sourcerer::SourceType
      end

      @type_class = @core_instance.get_type_class :foo

      expect(@type_class).to eq Sourcerer::SourceType::Foo
    end
  end
end
