RSpec.describe Sourcerer::Packages::Bower do
  describe '#search' do
    before do
      @bower = Sourcerer::Packages::Bower.allocate
      @package = Sourcerer::Package.allocate

      allow(@bower).to receive(:name).and_return 'bower_package'
      allow(@bower).to receive(:version).and_return '1.2.3'
      allow(@bower).to receive(:versions).and_return ['1.2.3']
    end

    context 'when package is found' do
      before do
        allow(@bower).to receive(:get_url).and_return true
        allow(Sourcerer::Package).to receive(:search).and_return({ success: [@package] })
        allow(@package).to receive(:version).and_return true
      end

      it 'should search the underlying bower source url for a package' do
        @bower.search

        expect(@bower).to have_received(:get_url).ordered
        expect(Sourcerer::Package).to have_received(:search).with({ name: 'bower_package', version: '1.2.3', type: :git }).ordered
        expect(@package).to have_received(:version).ordered
      end
    end

    context 'when package is not found' do
      before do
        allow(@bower).to receive(:get_url).and_return nil
        allow(Sourcerer::Package).to receive(:search)
        allow(@package).to receive(:version)
      end

      it 'should not search further' do
        @bower.search

        expect(@bower).to have_received(:get_url).ordered
        expect(Sourcerer::Package).to_not have_received(:search)
        expect(@package).to_not have_received(:version)
      end
    end
  end
end
