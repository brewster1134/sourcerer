# Basic package type sanity check
RSpec.describe Sourcerer::Packages do
  Sourcerer::Package.class_variable_get(:@@subclasses).each do |type, package_class|
    describe package_class do
      it 'should define a download method' do
        expect(package_class.instance_methods(false)).to include :download
      end

      it 'should define a search method' do
        expect(package_class.instance_methods(false)).to include :search
      end

      it 'should define a versions method' do
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
        def initialize name:, version:; end
        def version; '1.2.3'; end
      end
      class SearchBar
        def initialize name:, version:; end
        def version; '1.2.3'; end
      end
      class SearchBaz
        def initialize name:, version:; end
        def version; '1.2.3'; end
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
        @packages = Sourcerer::Package.search name: 'name', version: '1.2.3', type: :any
      end

      it 'should search each package type' do
        expect(SearchFoo).to have_received(:new).with(name: 'name', version: '1.2.3')
        expect(SearchBar).to have_received(:new).with(name: 'name', version: '1.2.3')
        expect(SearchBaz).to have_received(:new).with(name: 'name', version: '1.2.3')
      end

      it 'should return an array with the packages' do
        expect(@packages).to eq({
          success: [@package_foo, @package_bar, @package_baz],
          fail: []
        })
      end
    end

    context 'when searching multiple types' do
      before do
        @packages = Sourcerer::Package.search name: 'name', version: '1.2.3', type: [:type_one, :type_three]
      end

      it 'should search only the specific package types' do
        expect(SearchFoo).to have_received(:new).with(name: 'name', version: '1.2.3')
        expect(SearchBar).to_not have_received(:new)
        expect(SearchBaz).to have_received(:new).with(name: 'name', version: '1.2.3')
      end

      it 'should return an array with the packages' do
        expect(@packages).to eq({
          success: [@package_foo, @package_baz],
          fail: []
        })
      end
    end

    context 'when searching a single type' do
      before do
        @packages = Sourcerer::Package.search name: 'name', version: '1.2.3', type: :type_two
      end

      it 'should search only the specific package type' do
        expect(SearchFoo).to_not have_received(:new)
        expect(SearchBar).to have_received(:new).with(name: 'name', version: '1.2.3')
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
      @package.instance_variable_set :@errors, [:foo]
      @package.instance_variable_set :@type, :bar

      allow(Sourcerer::Error).to receive(:new).and_return :bar
    end

    after do
      allow(Sourcerer::Error).to receive(:new).and_call_original
    end

    it 'should add an error from the package parent class' do
      allow(@package.class).to receive(:name).and_return 'Sourcerer::Package'
      result = @package.add_error 'error'

      expect(Sourcerer::Error).to have_received(:new).with 'package.error', Hash
      expect(result).to eq [:bar, :foo]
    end

    it 'should add an error from a type subclass' do
      allow(@package.class).to receive(:name).and_return 'Sourcerer::Packages::Foo'
      result = @package.add_error 'error'

      expect(Sourcerer::Error).to have_received(:new).with 'package.bar.error', Hash
      expect(result).to eq [:foo, :bar]
    end
  end

  describe '#install' do
    before do
      @package = Sourcerer::Package.allocate
      @cache_dir = File.expand_path(File.join(__dir__, '..', '..', 'fixtures', 'cache'))
      @package_cache_dir = File.expand_path(File.join(@cache_dir, 'foo', '1.2.3'))
      @package_dir = File.expand_path(File.join(__dir__, '..', '..', 'fixtures', 'packages'))
      @destination = File.expand_path(File.join(@package_dir, 'foo', '1.2.3'))

      allow(File).to receive(:join).and_return @package_cache_dir
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:cp_r)
      allow(@package).to receive(:download)
      allow(@package).to receive(:add_error)
    end

    after do
      allow(File).to receive(:join).and_call_original
      allow(Dir).to receive(:glob).and_call_original
      allow(FileUtils).to receive(:mkdir_p).and_call_original
      allow(FileUtils).to receive(:cp_r).and_call_original
    end

    context 'when package is cached' do
      before do
        allow(Dir).to receive(:glob).and_return ['package']

        @package.install name: 'foo', version: '1.2.3', destination: @packages_dir, force: false
      end

      it 'should copy the cached package' do
        expect(FileUtils).to_not have_received(:mkdir_p)
        expect(@package).to_not have_received(:download)
        expect(@package).to_not have_received(:add_error)
        expect(FileUtils).to have_received(:cp_r).with("#{@package_cache_dir}/.", @packages_dir).ordered
      end
    end

    context 'when package is not cached' do
      context 'when download succeeds' do
        before do
          allow(Dir).to receive(:glob).and_return([], ['package'])

          @package.install name: 'foo', version: '1.2.3', destination: @packages_dir, force: false
        end

        it 'should run in the right order' do
          expect(FileUtils).to have_received(:mkdir_p).with(@package_cache_dir).ordered
          expect(@package).to have_received(:download).with({ to: @package_cache_dir }).ordered
          expect(@package).to_not have_received(:add_error)
          expect(FileUtils).to have_received(:cp_r).with("#{@package_cache_dir}/.", @packages_dir).ordered
        end
      end

      context 'when download fails' do
        before do
          allow(Dir).to receive(:glob).and_return([])

          @package.install name: 'foo', version: '1.2.3', destination: @packages_dir, force: false
        end

        it 'should run in the right order' do
          expect(FileUtils).to have_received(:mkdir_p).with(@package_cache_dir).ordered
          expect(@package).to have_received(:download).with({ to: @package_cache_dir }).ordered
          expect(@package).to have_received(:add_error).with('download_fail', Hash).ordered
          expect(FileUtils).to_not have_received(:cp_r)
        end
      end
    end
  end

  #
  # PRIVATE CLASS METHODS
  #
  describe '.inherited' do
    before do
      module InheritedFoo
        class InheritedBar < Sourcerer::Package
        end
      end
    end

    it 'should register the new subclass' do
      expect(Sourcerer::Package.class_variable_get(:@@subclasses)).to include({ package_spec: InheritedFoo::InheritedBar })
    end

    it 'should add the type class variable' do
      expect(InheritedFoo::InheritedBar.class_variable_get(:@@type)).to eq :package_spec
    end
  end

  describe '.subclasses' do
    before do
      subclasses = Sourcerer::Package.class_variable_get(:@@subclasses)
      subclasses[:file_name] = :subclass
      Sourcerer::Package.class_variable_set(:@@subclasses, subclasses)
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
      @package = Sourcerer::Package.allocate

      allow(@package).to receive(:versions)
    end

    context 'when search for the package fails' do
      before do
        allow(@package).to receive(:search).and_return false
      end

      it 'should not try to match the version' do
        expect(@package).to receive(:search).ordered
        expect(@package).to receive(:add_error).ordered
        expect(@package).to_not receive(:find_matching_version)

        @package.send(:initialize, name: 'package_foo', version: '1.2.3')
      end
    end

    context 'when finding a version fails' do
      before do
        allow(@package).to receive(:search).and_return true
        allow(@package).to receive(:find_matching_version).and_return false
      end

      it 'should try to match the version' do
        expect(@package).to receive(:search).ordered
        expect(@package).to receive(:versions).ordered
        expect(@package).to receive(:find_matching_version).ordered
        expect(@package).to receive(:add_error).ordered

        @package.send(:initialize, name: 'package_foo', version: 'version')
      end
    end

    context 'when search and version succeed' do
      before do
        allow(@package).to receive(:search).and_return true
        allow(@package).to receive(:find_matching_version).and_return '1.2.3'
      end

      it 'should set the version' do
        expect(@package).to receive(:search).ordered
        expect(@package).to receive(:find_matching_version).ordered
        expect(@package).to_not receive(:add_error)

        @package.send(:initialize, name: 'package_foo', version: 'version')

        expect(@package.version).to eq '1.2.3'
      end
    end
  end

  describe '.latest' do
    context 'if subclass has method defined' do
      it 'should call it' do
        class HasLatestMethod < Sourcerer::Package
          def latest; 'latest version'; end
        end

        @package = HasLatestMethod.allocate

        expect(@package.send(:latest)).to eq 'latest version'
      end
    end

    context 'if subclass does not have method defined' do
      it 'should call use the first version' do
        class NoLatestMethod < Sourcerer::Package
          def versions; ['first version', 'second version']; end
        end

        @package = NoLatestMethod.allocate

        expect(@package.send(:latest)).to eq 'first version'
      end
    end
  end
end
