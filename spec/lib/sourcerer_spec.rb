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
      @error = Sourcerer::Error.allocate
      @package = Sourcerer::Package.allocate

      allow(Sourcerer::Error).to receive(:new).and_return @error
      allow(@error).to receive(:print)
      allow(@package).to receive(:install)
      allow(@sourcerer).to receive(:print_package_errors)
    end

    after do
      allow(Sourcerer::Error).to receive(:new).and_call_original
    end

    context 'when no packages are found' do
      before do
        allow(Sourcerer::Package).to receive(:search).and_return({ success: [], fail: 'package fail' })

        @sourcerer.send(:initialize, name: 'foo', cli: true, destination: 'destination', force: false, type: :foo, version: '1.2.3')
      end

      it 'should show package errors' do
        expect(Sourcerer::Error).to have_received(:new).ordered
        expect(@sourcerer).to have_received(:print_package_errors).with('package fail').ordered
      end
    end

    context 'when 1 package is found' do
      before do
        allow(Sourcerer::Package).to receive(:search).and_return({ success: [@package] })

        @sourcerer.send(:initialize, name: 'foo', cli: true, destination: 'destination', force: false, type: :foo, version: '1.2.3')
      end

      it 'should install the package' do
        expect(Sourcerer::Error).to_not have_received(:new)
        expect(@package).to have_received(:install).with({ name: 'foo', destination: String, force: false, version: '1.2.3' })
      end
    end

    context 'when multiple packages are found' do
      before do
        allow(Sourcerer::Package).to receive(:search).and_return({ success: [@package, @package] })
        allow(@sourcerer).to receive(:prompt_for_package).and_return(@package)
        allow(@package).to receive(:type).and_return('foo', 'bar')

        @sourcerer.send(:initialize, name: 'foo', cli: true, destination: 'destination', force: false, type: :foo, version: '1.2.3')
      end

      it 'should create an error' do
        expect(Sourcerer::Error).to have_received(:new).with(String, hash_including({ types: 'foo, bar' }))
      end
    end
  end
end
