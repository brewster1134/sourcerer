RSpec.describe Sourcerer do
  describe '.install' do
    context 'when a single package is found' do
      before do
        @package = Sourcerer::Package.allocate

        allow(@package).to receive(:install)
        allow(Sourcerer::Package).to receive(:search).and_return({
          success: [@package]
        })

        @sourcerer_install = Sourcerer.install 'package_foo', destination: 'packages_dir', version: '1.2.3', type: 'foo_type'
      end

      it 'should install the package in the right order' do
        expect(Sourcerer::Package).to have_received(:search).with(package_name: 'package_foo', version: '1.2.3', type: :foo_type).ordered
        expect(@package).to have_received(:install).with(destination: 'packages_dir').ordered
      end
    end

    context 'when multiple packages are found' do
      before do
        @package_one = Sourcerer::Package.allocate
        @package_two = Sourcerer::Package.allocate

        allow(@package_one).to receive(:type).and_return 'foo_type'
        allow(@package_two).to receive(:type).and_return 'bar_type'
        allow(Sourcerer::Package).to receive(:search).and_return({
          success: [@package_one, @package_two]
        })

        @sourcerer_install = ->{ Sourcerer.install 'package_foo', destination: 'packages_dir', version: '1.2.3', type: :any }
      end

      it 'should raise an error' do
        expect{ @sourcerer_install[] }.to raise_error Sourcerer::Error, 'multiple_packages_found package_foo foo_type, bar_type'
      end
    end

    context 'when no packages are found' do
      before do
        @package = Sourcerer::Package.allocate
        @error = Sourcerer::Error.allocate

        allow(@error).to receive(:message).and_return 'package error'
        allow(@package).to receive(:errors).and_return [@error]
        allow(@package).to receive(:install)
        allow(S).to receive(:ay)
        allow(Sourcerer::Package).to receive(:search).and_return({
          success: [],
          fail: [@package]
        })

        @sourcerer_install = ->{ Sourcerer.install 'package_foo', destination: 'packages_dir', version: '1.2.3', type: :any }
      end

      after do
        allow(S).to receive(:ay).and_call_original
      end

      it 'should raise an error' do
        expect{ @sourcerer_install[] }.to raise_error { |error|
          expect(@package).to_not have_received(:install)
          expect(S).to have_received(:ay).with 'package error', Hash
          expect(error).to be_a Sourcerer::Error
          expect(error.message).to eq 'no_package_found package_foo'
        }
      end
    end
  end
end
