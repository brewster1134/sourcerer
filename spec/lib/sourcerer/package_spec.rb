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
        def initialize package_name:, version:, type:
        end
        def found?
        end
      end

      class SearchBar
        def initialize package_name:, version:, type:
        end
        def found?
        end
      end

      Sourcerer::Package.class_variable_set :@@subclasses, {
        type_one: SearchFoo,
        type_two: SearchBar
      }

      @package_foo = SearchFoo.allocate
      @package_bar = SearchBar.allocate

      allow(SearchFoo).to receive(:new).and_return @package_foo
      allow_any_instance_of(SearchFoo).to receive(:found?).and_return true
      allow(SearchBar).to receive(:new).and_return @package_bar
      allow_any_instance_of(SearchBar).to receive(:found?).and_return true
    end

    context 'when searching any type' do
      before do
        @packages = Sourcerer::Package.search package_name: 'package_name', version: '1.2.3', type: :any
      end

      it 'should search each package type' do
        expect(SearchFoo).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_one)
        expect(SearchBar).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_two)
      end

      it 'should return an array with the packages' do
        expect(@packages).to eq [@package_foo, @package_bar]
      end
    end

    context 'when searching a specific type' do
      before do
        @packages = Sourcerer::Package.search package_name: 'package_name', version: '1.2.3', type: 'type_two'
      end

      it 'should search only the specific package type' do
        expect(SearchFoo).to_not have_received(:new)
        expect(SearchBar).to have_received(:new).with(package_name: 'package_name', version: '1.2.3', type: :type_two)
      end

      it 'should return an array with the package' do
        expect(@packages).to eq [@package_bar]
      end
    end
  end

  #
  # PUBLIC INSTANCE METHODS
  #

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
        def search package_name:, version:
        end
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
