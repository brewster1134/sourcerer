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
        def initialize name:, version:, type:; end
        def exists; true; end
      end
      class SearchBar
        def initialize name:, version:, type:; end
        def exists; true; end
      end
      class SearchBaz
        def initialize name:, version:, type:; end
        def exists; true; end
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
        expect(SearchFoo).to have_received(:new).with(name: 'name', version: '1.2.3', type: :type_one)
        expect(SearchBar).to have_received(:new).with(name: 'name', version: '1.2.3', type: :type_two)
        expect(SearchBaz).to have_received(:new).with(name: 'name', version: '1.2.3', type: :type_three)
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
        @packages = Sourcerer::Package.search name: 'name', version: '1.2.3', type: [:type_one, :type_three]
      end

      it 'should search only the specific package types' do
        expect(SearchFoo).to have_received(:new).with(name: 'name', version: '1.2.3', type: :type_one)
        expect(SearchBar).to_not have_received(:new)
        expect(SearchBaz).to have_received(:new).with(name: 'name', version: '1.2.3', type: :type_three)
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
        @packages = Sourcerer::Package.search name: 'name', version: '1.2.3', type: :type_two
      end

      it 'should search only the specific package type' do
        expect(SearchFoo).to_not have_received(:new)
        expect(SearchBar).to have_received(:new).with(name: 'name', version: '1.2.3', type: :type_two)
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

      allow(Sourcerer::Error).to receive(:new).and_return :bar
    end

    after do
      allow(Sourcerer::Error).to receive(:new).and_call_original
    end

    it 'should prepend a Sourcerer::Error instance' do
      result = @package.add_error 'error', prepend: true

      expect(Sourcerer::Error).to have_received(:new).with 'package.error', prepend: true
      expect(result).to eq [:bar, :foo]
    end

    it 'should append a Sourcerer::Error instance' do
      result = @package.add_error 'error', prepend: false

      expect(Sourcerer::Error).to have_received(:new).with 'package.error', prepend: false
      expect(result).to eq [:foo, :bar]
    end
  end

  describe '#install' do
    before do
      @package = Sourcerer::Package.allocate
      allow(@package).to receive(:download)
      allow(@package).to receive(:add_error)
      allow(@package).to receive(:name).and_return 'name'
      allow(@package).to receive(:type).and_return :spec
      allow(@package).to receive(:version).and_return '1.2.3'
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:cp_r)

      @cache_dir = File.expand_path(File.join(__dir__, '..', '..', 'fixtures', 'cache'))
      @packages_dir = File.expand_path(File.join(__dir__, '..', '..', 'fixtures', 'packages'))
      @cache_destination_path = File.join(@cache_dir, @package.name, @package.version)
      @packages_destination_path = File.join(@packages_dir, @package.name, @package.version)

      stub_const "Sourcerer::DEFAULT_CACHE_DIRECTORY", @cache_dir

      # start with a clean directory
      FileUtils.rm_rf "#{@cache_dir}/*"
      FileUtils.rm_rf "#{@packages_dir}/*"
    end

    after do
      allow(Dir).to receive(:glob).and_call_original
      allow(FileUtils).to receive(:mkdir_p).and_call_original
      allow(FileUtils).to receive(:cp_r).and_call_original
    end

    context 'when package is cached' do
      before do
        allow(Dir).to receive(:glob).and_return [1]

        @package.install destination: @packages_dir, force: false
      end

      it 'should run in the right order' do
        expect(FileUtils).to have_received(:mkdir_p).with(@cache_destination_path).ordered
        expect(@package).to_not have_received(:download)
        expect(@package).to_not have_received(:add_error)
        expect(FileUtils).to have_received(:cp_r).with("#{@cache_destination_path}/.", @package.destination).ordered
      end
    end

    context 'when package is not cached' do
      context 'when download succeeds' do
        before do
          allow(Dir).to receive(:glob).and_return [1]

          @package.install destination: @packages_dir, force: true
        end

        it 'should run in the right order' do
          expect(FileUtils).to have_received(:mkdir_p).with(@cache_destination_path).ordered
          expect(@package).to have_received(:download).with({ to: @cache_destination_path  }).ordered
          expect(@package).to_not have_received(:add_error)
          expect(FileUtils).to have_received(:cp_r).with("#{@cache_destination_path}/.", @package.destination).ordered
        end
      end

      context 'when download fails' do
        before do
          allow(Dir).to receive(:glob).and_return []

          @package.install destination: @packages_dir, force: true
        end

        it 'should run in the right order' do
          expect(FileUtils).to have_received(:mkdir_p).with(@cache_destination_path).ordered
          expect(@package).to have_received(:download).with({ to: @cache_destination_path  }).ordered
          expect(@package).to have_received(:add_error).ordered
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
      end

      allow_any_instance_of(InitializeFoo).to receive(:search).and_return true
      allow_any_instance_of(InitializeFoo).to receive(:versions).and_return :poop
      allow_any_instance_of(InitializeFoo).to receive(:find_matching_version).and_return :fart
    end

    after do
      Sourcerer::Package.class_variable_get(:@@subclasses).delete(:package_spec)
    end

    context 'when search fails' do
      before do
        allow_any_instance_of(InitializeFoo).to receive(:search).and_return false
      end

      it 'should return with an error' do
        expect_any_instance_of(InitializeFoo).to receive(:search)
        expect_any_instance_of(InitializeFoo).to receive(:add_error)
        expect_any_instance_of(InitializeFoo).to_not receive(:find_matching_version)

        version = InitializeFoo.new name: 'package_foo', version: '1.2.3', type: 'type'

        expect(version.exists).to eq false
      end
    end

    context 'when finding a version fails' do
      before do
        allow_any_instance_of(InitializeFoo).to receive(:search).and_return true
        allow_any_instance_of(InitializeFoo).to receive(:find_matching_version).and_return false
      end

      it 'should return with an error' do
        expect_any_instance_of(InitializeFoo).to receive(:search)
        expect_any_instance_of(InitializeFoo).to receive(:find_matching_version)
        expect_any_instance_of(InitializeFoo).to receive(:add_error)

        version = InitializeFoo.new name: 'package_foo', version: 'version', type: 'type'

        expect(version.exists).to eq false
      end
    end

    context 'when search and version succeed' do
      before do
        allow_any_instance_of(InitializeFoo).to receive(:search).and_return true
        allow_any_instance_of(InitializeFoo).to receive(:find_matching_version).and_return true
      end

      it 'should return true' do
        expect_any_instance_of(InitializeFoo).to receive(:search)
        expect_any_instance_of(InitializeFoo).to receive(:find_matching_version)
        expect_any_instance_of(InitializeFoo).to_not receive(:add_error)

        version = InitializeFoo.new name: 'package_foo', version: 'version', type: 'type'

        expect(version.exists).to eq true
      end
    end
  end
end
