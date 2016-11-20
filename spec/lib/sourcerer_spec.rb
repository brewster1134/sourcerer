RSpec.describe Sourcerer do
  before do
    allow(Sourcerer::Package).to receive(:search)
  end

  after do
    allow(Sourcerer::Package).to receive(:search).and_call_original
  end

  context 'when a single package is found' do
    before do
      @package = Sourcerer::Package.allocate

      allow(@package).to receive(:install)
      allow(Sourcerer::Package).to receive(:search).and_return [@package]

      Sourcerer.install 'package_foo', version: '1.2.3', type: 'bower'
    end

    it 'should not raise an error' do
      expect(Sourcerer::Package).to have_received(:search).with('package_foo', version: '1.2.3', type: 'bower').ordered
      expect(@package).to have_received(:install).ordered
    end
  end

  context 'when multiple packages are found' do
    before do
      @package_one = Sourcerer::Package.allocate
      @package_two = Sourcerer::Package.allocate

      allow(@package_one).to receive(:type).and_return 'bower'
      allow(@package_two).to receive(:type).and_return 'git'

      allow(Sourcerer::Package).to receive(:search).and_return [@package_one, @package_two]
    end

    it 'should raise an error' do
      expect{ Sourcerer.install('package_foo', version: '1.2.3', type: :any) }.to raise_error Sourcerer::Error, 'multiple_packages_found package_foo bower, git'
    end
  end
end
