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

        allow(@package).to receive(:copy)
        allow(@package).to receive(:download)
        allow(@package).to receive(:type)
        allow(Sourcerer::Package).to receive(:search).and_return [@package]

        @cli.options = { version: '1.2.3', type: 'foo_type', destination: 'packages_dir' }
        @cli.install 'package_foo'
      end

      it 'should install the package in the right order' do
        expect(A).to_not have_received(:sk)
        expect(@package).to_not have_received(:type)

        expect(Sourcerer::Package).to have_received(:search).with(package_name: 'package_foo', version: '1.2.3', type: 'foo_type').ordered
        expect(@package).to have_received(:download).ordered
        expect(@package).to have_received(:copy).with(destination: 'packages_dir').ordered
      end
    end

    context 'when multiple packages are found' do
      before do
        @package_one = Sourcerer::Package.allocate
        @package_two = Sourcerer::Package.allocate

        allow(@package_one).to receive(:copy)
        allow(@package_one).to receive(:download)
        allow(@package_one).to receive(:type).and_return 'foo_type'
        allow(@package_two).to receive(:copy)
        allow(@package_two).to receive(:download)
        allow(@package_two).to receive(:type).and_return 'bar_type'
        allow(A).to receive(:sk).and_return('bar_type': @package_two)
        allow(Sourcerer::Package).to receive(:search).and_return [@package_one, @package_two]

        @cli.options = { version: '1.2.3', type: :any, destination: 'packages_dir' }
        @cli.install 'package_foo'
      end

      it 'should prompt the user & install the package in the right order' do
        expect(@package_one).to_not have_received(:download)
        expect(@package_one).to_not have_received(:copy)

        expect(Sourcerer::Package).to have_received(:search).with(package_name: 'package_foo', version: '1.2.3', type: :any).ordered
        expect(@package_one).to have_received(:type).ordered
        expect(@package_two).to have_received(:type).ordered
        expect(A).to have_received(:sk).with(include('multiple_packages_found', 'package_foo'), type: :multiple_choice, choices: { 'foo_type' => @package_one, 'bar_type' => @package_two }, max: 1).ordered
        expect(@package_two).to have_received(:download).ordered
        expect(@package_two).to have_received(:copy).with(destination: 'packages_dir').ordered
      end
    end

    context 'when no packages are found' do
      before do
        allow(Sourcerer::Package).to receive(:search).and_return []

        @cli.options = { version: '1.2.3', type: :any, destination: 'packages_dir' }
        @cli.install 'package_foo'
      end

      it 'should show the user an error in the right order' do
        expect(A).to_not have_received(:sk)

        expect(Sourcerer::Package).to have_received(:search).with(package_name: 'package_foo', version: '1.2.3', type: :any).ordered
        expect(S).to have_received(:ay).with('no_package_found package_foo', Hash).ordered
      end
    end
  end
end
