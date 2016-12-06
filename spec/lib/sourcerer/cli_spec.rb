RSpec.describe Sourcerer::Cli do
  describe '#install' do
    before do
      @cli = Sourcerer::Cli.allocate

      allow(A).to receive(:sk)
      allow(S).to receive(:ay)
    end

    after do
      allow(A).to receive(:sk).and_call_original
      allow(S).to receive(:ay).and_call_original
    end

    context 'when a single package is found' do
      before do
        @package = Sourcerer::Package.allocate

        allow(@package).to receive(:install)
        allow(@package).to receive(:type)
        allow(Sourcerer::Package).to receive(:search).and_return({
          success: [@package]
        })

        @cli.options = { version: '1.2.3', type: 'foo_type', destination: 'packages_dir' }
        @cli.install 'package_foo'
      end

      it 'should install the package in the right order' do
        expect(A).to_not have_received(:sk)
        expect(@package).to_not have_received(:type)

        expect(Sourcerer::Package).to have_received(:search).with(package_name: 'package_foo', version: '1.2.3', type: :foo_type).ordered
        expect(@package).to have_received(:install).ordered
      end
    end

    context 'when multiple packages are found' do
      before do
        @package_one = Sourcerer::Package.allocate
        @package_two = Sourcerer::Package.allocate

        allow(@package_one).to receive(:install)
        allow(@package_one).to receive(:type).and_return 'foo_type'
        allow(@package_two).to receive(:install)
        allow(@package_two).to receive(:type).and_return 'bar_type'
        allow(A).to receive(:sk).and_return('bar_type': @package_two)
        allow(Sourcerer::Package).to receive(:search).and_return({
          success: [@package_one, @package_two]
        })

        @cli.options = { version: '1.2.3', type: 'any', destination: 'packages_dir' }
        @cli.install 'package_foo'
      end

      it 'should prompt the user & install the package in the right order' do
        expect(@package_one).to_not have_received(:install)

        expect(Sourcerer::Package).to have_received(:search).with(package_name: 'package_foo', version: '1.2.3', type: :any).ordered
        expect(@package_one).to have_received(:type).ordered
        expect(@package_two).to have_received(:type).ordered
        expect(A).to have_received(:sk).with(include('multiple_packages_found', 'package_foo'), type: :multiple_choice, choices: { 'foo_type' => @package_one, 'bar_type' => @package_two }, max: 1).ordered
        expect(@package_two).to have_received(:install).ordered
      end
    end

    context 'when no packages are found' do
      before do
        @package = Sourcerer::Package.allocate
        @error = Sourcerer::Error.allocate

        allow(@error).to receive(:message).and_return 'package error'
        allow(@package).to receive(:errors).and_return [@error]
        allow(@package).to receive(:install)
        allow(Sourcerer::Package).to receive(:search).and_return({
          success: [],
          fail: [@package]
        })

        @cli.options = { version: '1.2.3', type: 'any', destination: 'packages_dir' }
        @cli.install 'package_foo'
      end

      it 'should show the user an error in the right order' do
        expect(A).to_not have_received(:sk)
        expect(@package).to_not have_received(:install)

        expect(Sourcerer::Package).to have_received(:search).with(package_name: 'package_foo', version: '1.2.3', type: :any).ordered
        expect(S).to have_received(:ay).with('package error', Hash).exactly(1).times.ordered
      end
    end
  end
end
