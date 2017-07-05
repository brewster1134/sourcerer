RSpec.describe Sourcerer do
  describe '.install' do
    before do
      allow(Sourcerer).to receive(:new)
    end

    after do
      allow(Sourcerer).to receive(:new).and_call_original
    end

    it 'should initialize a new Sourcerer instance with defaults' do
      Sourcerer.install 'foo'

      expect(Sourcerer).to have_received(:new).with({ name: 'foo', cli: Sourcerer::DEFAULT_CLI, destination: Sourcerer::DEFAULT_DESTINATION, force: Sourcerer::DEFAULT_FORCE, type: Sourcerer::DEFAULT_TYPE, version: Sourcerer::DEFAULT_VERSION })
    end
  end

  describe '#initialize' do
    before do
      @options = { options: true }
      @package = Sourcerer::Package.allocate
      @sourcerer = Sourcerer.allocate

      allow(Sourcerer::Package).to receive(:search).and_return(:packages)
      allow(@package).to receive(:install)
      allow(@sourcerer).to receive(:get_package).and_return(@package)
      allow(@sourcerer).to receive(:print_package_errors)
    end

    after do
      allow(Sourcerer::Package).to receive(:search).and_call_original
    end

    context 'when package is found' do
      before do
        allow(@package).to receive(:version).and_return(true)

        @sourcerer.send :initialize, @options
      end

      it 'should install the package' do
        expect(Sourcerer::Package).to have_received(:search).with(@options).ordered
        expect(@sourcerer).to have_received(:get_package).with(:packages, @options).ordered
        expect(@package).to have_received(:version).ordered
        expect(@package).to have_received(:install).ordered
        expect(@sourcerer).to_not have_received(:print_package_errors)
      end
    end

    context 'when package is not found' do
      before do
        allow(@package).to receive(:version).and_return(false)

        @sourcerer.send :initialize, @options
      end

      it 'should not install the package and show the errors' do
        expect(Sourcerer::Package).to have_received(:search).with(@options).ordered
        expect(@sourcerer).to have_received(:get_package).with(:packages, @options).ordered
        expect(@package).to have_received(:version).ordered
        expect(@package).to_not have_received(:install)
        expect(@sourcerer).to have_received(:print_package_errors).with([ @package ]).ordered
      end
    end
  end

  describe '#get_package' do
    before do
      @error = Sourcerer::Error.allocate
      @options = { cli: true, type: [:spec] }
      @package = Sourcerer::Package.allocate
      @sourcerer = Sourcerer.allocate

      allow(Sourcerer::Error).to receive(:new).and_return(@error)
      allow(@error).to receive(:print)
      allow(@package).to receive(:type).and_return('foo', 'bar')
      allow(@sourcerer).to receive(:print_package_errors)
      allow(@sourcerer).to receive(:prompt_for_package)
    end

    after do
      allow(Sourcerer::Error).to receive(:new).and_call_original
    end

    context 'when no packages are found' do
      before do
        @return = @sourcerer.send(:get_package, { success: [], fail: [:error] }, @options)
      end

      it 'should show package errors' do
        expect(Sourcerer::Error).to have_received(:new).ordered
        expect(@error).to have_received(:print).ordered
        expect(@sourcerer).to have_received(:print_package_errors).with([:error]).ordered
      end

      it 'should return nil' do
        expect(@return).to be_nil
      end
    end

    context 'when 1 package is found' do
      before do
        @return = @sourcerer.send(:get_package, { success: [@package], fail: [] }, @options)
      end

      it 'should install the package' do
        expect(Sourcerer::Error).to_not have_received(:new)
        expect(@error).to_not have_received(:print)
        expect(@sourcerer).to_not have_received(:print_package_errors)
      end

      it 'should return the package' do
        expect(@return).to be @package
      end
    end

    context 'when multiple packages are found' do
      before do
        @return = @sourcerer.send(:get_package, { success: [@package, @package], fail: [] }, @options)
      end

      it 'should create an error' do
        expect(Sourcerer::Error).to have_received(:new).with(String, hash_including({ types: 'foo, bar' })).ordered
        expect(@error).to have_received(:print).ordered
        expect(@sourcerer).to_not have_received(:print_package_errors)
      end

      it 'should return nil' do
        expect(@return).to be_nil
      end
    end
  end
end
