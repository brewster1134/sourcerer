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
      @sourcerer = Sourcerer.allocate
      @package = Sourcerer::Package.allocate
      @error = Sourcerer::Error.allocate
      @options = { cli: false }

      allow(Sourcerer::Package).to receive(:search)
      allow(@sourcerer).to receive(:get_package).and_return(@package)
      allow(@package).to receive(:install)
      allow(@error).to receive(:print)
    end

    after do
      allow(Sourcerer::Package).to receive(:search).and_call_original
    end

    context 'when package is found' do
      before do
        allow(@sourcerer).to receive(:get_package).and_return(@package)

        @sourcerer.send :initialize, @options
      end

      it 'should install the package' do
        expect(Sourcerer::Package).to have_received(:search).with(@options).ordered
        expect(@sourcerer).to have_received(:get_package).with(nil, @options).ordered
        expect(@package).to have_received(:install).ordered
      end
    end

    context 'when package is not found' do
      before do
        allow(@sourcerer).to receive(:get_package).and_raise(@error)

        @return = -> { @sourcerer.send :initialize, @options }
      end

      it 'should not install the package and show the errors' do
        expect{ @return.call }.to raise_error do |e|
          expect(e).to be(@error)
          expect(Sourcerer::Package).to have_received(:search).with(@options).ordered
          expect(@sourcerer).to have_received(:get_package).with(nil, @options).ordered
          expect(@package).to_not have_received(:install)
        end
      end
    end
  end

  describe '#get_package' do
    before do
      @error = Sourcerer::Error.allocate
      @options = { cli: false }
      @package = Sourcerer::Package.allocate
      @sourcerer = Sourcerer.allocate

      @sourcerer.instance_variable_set '@errors', []

      allow(Sourcerer::Error).to receive(:new).and_return(@error)
      allow(@error).to receive(:print)
      allow(@package).to receive(:type).and_return('foo', 'bar')
      allow(@sourcerer).to receive(:prompt_for_package)
      allow(@sourcerer).to receive(:print_package_errors)
    end

    after do
      allow(Sourcerer::Error).to receive(:new).and_call_original
    end

    context 'when no packages are found' do
      before do
        @return = -> { @sourcerer.send(:get_package, { success: [], fail: [:error] }, @options) }
      end

      it 'raise an error' do
        expect{ @return.call }.to raise_error do |e|
          expect(e).to be(@error)
        end
      end
    end

    context 'when 1 package is found' do
      before do
        @return = @sourcerer.send(:get_package, { success: [@package], fail: [] }, @options)
      end

      it 'should return the package' do
        expect(@return).to be @package
      end
    end

    context 'when multiple packages are found' do
      before do
        @return =-> { @sourcerer.send(:get_package, { success: [@package, @package], fail: [] }, @options) }
      end

      it 'raise an error' do
        expect{ @return.call }.to raise_error do |e|
          expect(e).to be(@error)
        end
      end
    end
  end
end
