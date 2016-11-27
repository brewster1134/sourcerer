RSpec.describe Sourcerer do
  describe '.install' do
    context 'when a single package is found' do
      before do
        @package = Sourcerer::Package.allocate

        allow(@package).to receive(:copy)
        allow(@package).to receive(:download)
        allow(Sourcerer::Package).to receive(:search).and_return [@package]

        @sourcerer_install = Sourcerer.install 'package_foo', destination: 'packages_dir', version: '1.2.3', type: 'foo_type'
      end

      it 'should install the package in the right order' do
        expect(Sourcerer::Package).to have_received(:search).with(package_name: 'package_foo', version: '1.2.3', type: 'foo_type').ordered
        expect(@package).to have_received(:download).ordered
        expect(@package).to have_received(:copy).with(destination: 'packages_dir').ordered
      end
    end

    context 'when multiple packages are found' do
      before do
        @package_one = Sourcerer::Package.allocate
        @package_two = Sourcerer::Package.allocate

        allow(@package_one).to receive(:type).and_return 'foo_type'
        allow(@package_two).to receive(:type).and_return 'bar_type'
        allow(Sourcerer::Package).to receive(:search).and_return [@package_one, @package_two]

        @sourcerer_install = ->{ Sourcerer.install 'package_foo', destination: 'packages_dir', version: '1.2.3', type: :any }
      end

      it 'should raise an error' do
        expect{ @sourcerer_install[] }.to raise_error Sourcerer::Error, 'multiple_packages_found package_foo foo_type, bar_type'
      end
    end

    context 'when no packages are found' do
      before do
        allow(Sourcerer::Package).to receive(:search).and_return []

        @sourcerer_install = ->{ Sourcerer.install 'package_foo', destination: 'packages_dir', version: '1.2.3', type: :any }
      end

      it 'should raise an error' do
        expect{ @sourcerer_install[] }.to raise_error Sourcerer::Error, 'no_package_found package_foo'
      end
    end
  end
end
