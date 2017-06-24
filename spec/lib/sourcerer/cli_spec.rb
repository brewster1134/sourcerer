RSpec.describe Sourcerer::Cli do
  describe '#install' do
    before do
      @cli = Sourcerer::Cli.allocate
      @cli.options = { cli: true, destination: Sourcerer::DEFAULT_DESTINATION, force: Sourcerer::DEFAULT_FORCE, type: Sourcerer::DEFAULT_TYPE, version: Sourcerer::DEFAULT_VERSION }

      allow(Sourcerer).to receive(:install)
    end

    after do
      allow(Sourcerer).to receive(:install).and_call_original
    end

    it 'should initialize a new Sourcerer instance with defaults' do
      @cli.install 'foo'

      expect(Sourcerer).to have_received(:install).with('foo', @cli.options)
    end
  end
end
