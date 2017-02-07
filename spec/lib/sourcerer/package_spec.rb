# Basic package type sanity check
RSpec.describe Sourcerer::Packages do
  Sourcerer::Package.class_variable_get(:@@subclasses).each do |package_type, package_class|
    describe package_class do
      it 'should define a download method' do
        expect(package_class.instance_methods(false)).to include :download
      end

      it 'should define a search method' do
        expect(package_class.instance_methods(false)).to include :search
      end

      it 'should define a version method' do
        expect(package_class.instance_methods(false)).to include :versions
      end
    end
  end
end

RSpec.describe Sourcerer::Package do
  #
  # PUBLIC CLASS METHODS
  #
  describe '.search' do
    before do
      class SearchFoo
        def initialize package_name:, version:, type:; end
        def source; :foo; end
      end
      class SearchBar
        def initialize package_name:, version:, type:; end
        def source; :bar; end
      end
      class SearchBaz
        def initialize package_name:, version:, type:; end
        def source; :baz; end
      end

      Sourcerer::Package.class_variable_set :@@subclasses, {
        type_one: SearchFoo,
        type_two: SearchBar,
        type_three: SearchBaz,
      }

      @package_foo = SearchFoo.allocate
      @package_bar = SearchBar.allocate
      @package_baz = SearchBar.allocate

      allow(SearchFoo).to receive(:new).and_return @package_foo
      allow(SearchBar).to receive(:new).and_return @package_bar
      allow(SearchBaz).to receive(:new).and_return @package_baz
    end

    context 'when searching any type' do
      before do
        @packages = Sourcerer::Package.search package_name: 'package_name', version: '1.2.3', type: :any
      end

      it 'should search each package type' do
        expect(SearchFoo).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_one)
        expect(SearchBar).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_two)
        expect(SearchBaz).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_three)
      end

      it 'should return an array with the packages' do
        expect(@packages).to eq({
          success: [@package_foo, @package_bar, @package_baz],
          fail: []
        })
      end
    end

    context 'when searching multiple specific types' do
      before do
        @packages = Sourcerer::Package.search package_name: 'package_name', version: '1.2.3', type: ['type_one', 'type_three']
      end

      it 'should search only the specific package types' do
        expect(SearchFoo).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_one)
        expect(SearchBar).to_not have_received(:new)
        expect(SearchBaz).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_three)
      end

      it 'should return an array with the packages' do
        expect(@packages).to eq({
          success: [@package_foo, @package_baz],
          fail: []
        })
      end
    end

    context 'when searching a specific type' do
      before do
        @packages = Sourcerer::Package.search package_name: 'package_name', version: '1.2.3', type: 'type_two'
      end

      it 'should search only the specific package type' do
        expect(SearchFoo).to_not have_received(:new)
        expect(SearchBar).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_two)
        expect(SearchBaz).to_not have_received(:new)
      end

      it 'should return an array with the package' do
        expect(@packages).to eq({
          success: [@package_bar],
          fail: []
        })
      end
    end
  end

  #
  # PUBLIC INSTANCE METHODS
  #
  describe '#add_error' do
    before do
      @package = Sourcerer::Package.allocate
      @package.instance_variable_set :@errors, []

      allow(Sourcerer::Error).to receive(:new).and_return 'error_foo'

      @package.add_error 'add_error', foo: 'FOO'
    end

    after do
      allow(Sourcerer::Error).to receive(:new).and_call_original
    end

    it 'should add a Sourcerer::Error instance' do
      expect(Sourcerer::Error).to have_received(:new).with 'packages.add_error', foo: 'FOO'
      expect(@package.errors).to include 'error_foo'
    end
  end

  describe '#install' do
    before do
      @package = Sourcerer::Package.allocate
      @cache_dir = File.expand_path(File.join(__dir__, '..', '..', 'fixtures', 'cache'))
      @packages_dir = File.expand_path(File.join(__dir__, '..', '..', 'fixtures', 'packages'))

      # start with a clean directory
      FileUtils.rm_rf @packages_dir

      allow(@package).to receive(:download)
      allow(@package).to receive(:name).and_return 'package_name'
      allow(@package).to receive(:version).and_return '1.2.3'
      allow(FileUtils).to receive(:mkdir_p).and_call_original
      allow(FileUtils).to receive(:cp_r).and_call_original

      stub_const "Sourcerer::DEFAULT_CACHE_DIRECTORY", @cache_dir
    end

    context 'when package is cached' do
      before do
        allow(@package).to receive(:source).and_return 'cached_package'

        @package.install destination: @packages_dir
      end

      it 'should install in the right order' do
        expect(FileUtils).to have_received(:mkdir_p).with(@cache_dir).ordered
        expect(@package).to_not have_received(:download)
        expect(FileUtils).to have_received(:cp_r).with(File.join(@cache_dir, 'cached_package_123', '.'), File.join(@packages_dir, 'package_name')).ordered
      end

      it 'should install to the right directory' do
        expect(File.directory? File.join(@packages_dir, 'package_name')).to be true
        expect(File.exists? File.join(@packages_dir, 'package_name', 'cached_package.txt')).to be true
        expect(File.read(File.join(@packages_dir, 'package_name', 'cached_package.txt'))).to include 'Cached Package'
      end
    end

    context 'when package is not cached' do
      before do
        allow(@package).to receive(:source).and_return 'uncached_package'

        @package.install destination: @packages_dir
      end

      it 'should install in the right order' do
        expect(FileUtils).to have_received(:mkdir_p).with(@cache_dir).ordered
        expect(@package).to have_received(:download).with({ source: 'uncached_package', destination: File.join(@cache_dir, 'uncached_package_123') }).ordered
        expect(FileUtils).to have_received(:cp_r).with(File.join(@cache_dir, 'uncached_package_123', '.'), File.join(@packages_dir, 'package_name')).ordered
      end
    end
  end

  #
  # PRIVATE CLASS METHODS
  #
  describe '.inherited' do
    before do
      allow(Sourcerer::Package).to receive(:add_subclass)

      module InheritedFoo
        class InheritedBar < Sourcerer::Package
        end
      end
    end

    after do
      allow(Sourcerer::Package).to receive(:add_subclass).and_call_original

      Sourcerer::Package.class_variable_get(:@@subclasses).delete(:package_spec)
    end

    it 'should add the new subclass' do
      expect(Sourcerer::Package).to have_received(:add_subclass).with(:package_spec, InheritedFoo::InheritedBar)
    end
  end

  describe '.add_subclass' do
    before do
      Sourcerer::Package.add_subclass :file_name, :subclass
    end

    after do
      Sourcerer::Package.class_variable_get(:@@subclasses).delete(:file_name)
    end

    it 'should register the inherited class' do
      expect(Sourcerer::Package.class_variable_get(:@@subclasses)).to include file_name: :subclass
    end
  end

  describe '.subclasses' do
    before do
      subclasses = Sourcerer::Package.class_variable_get(:@@subclasses)
      subclasses[:file_name] = :subclass
      Sourcerer::Package.class_variable_set(:@@subclasses, subclasses)
    end

    after do
      Sourcerer::Package.class_variable_get(:@@subclasses).delete(:file_name)
    end

    context 'when passing a key' do
      it 'should return the subclass' do
        expect(Sourcerer::Package.subclasses(:file_name)).to eq :subclass
      end
    end

    context 'when not passing a key' do
      it 'should return all the subclasses' do
        expect(Sourcerer::Package.subclasses).to include file_name: :subclass
      end
    end
  end

  #
  # PRIVATE INSTANCE METHODS
  #
  describe '#initialize' do
    before do
      class InitializeFoo < Sourcerer::Package
        def search package_name:, version:; end
      end

      allow_any_instance_of(InitializeFoo).to receive(:search)
    end

    after do
      Sourcerer::Package.class_variable_get(:@@subclasses).delete(:package_spec)
    end

    context 'when passed a semantic version' do
      it 'should search with a semantic version' do
        expect_any_instance_of(InitializeFoo).to receive(:search).with(package_name: 'package_foo', version: Semantic::Version)

        InitializeFoo.new package_name: 'package_foo', version: '1.2.3', type: 'type'
      end
    end

    context 'when passed a non-semantic version' do
      it 'should search with a string' do
        expect_any_instance_of(InitializeFoo).to receive(:search).with(package_name: 'package_foo', version: 'version')

        InitializeFoo.new package_name: 'package_foo', version: 'version', type: 'type'
      end
    end
  end
end
