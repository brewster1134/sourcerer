RSpec.describe Sourcerer::Packages::Bower do
  describe '#search' do
    before do
      @bower = Sourcerer::Packages::Bower.allocate
      @package = Sourcerer::Package.allocate

      allow(Sourcerer::Packages::Git).to receive(:new).and_return @package
      allow(@bower).to receive(:name).and_return 'bower_package'
      allow(@bower).to receive(:version).and_return '1.2.3'
      allow(@bower).to receive(:versions).and_return ['1.2.3']
      allow(@package).to receive(:install).and_return ['1.2.3']
    end

    context 'when package is found' do
      before do
        allow(@bower).to receive(:get_git_url).and_return 'url.git'
        allow(@package).to receive(:version).and_return true
      end

      it 'should search the underlying bower source url for a package' do
        @bower.search

        expect(@bower).to have_received(:get_git_url).ordered
        expect(Sourcerer::Packages::Git).to have_received(:new).with({ name: 'url.git', version: '1.2.3' }).ordered
        expect(@package).to have_received(:version).ordered
      end
    end

    context 'when package is not found' do
      before do
        allow(@bower).to receive(:get_git_url).and_return nil
        allow(Sourcerer::Packages::Git).to receive(:new)
        allow(@package).to receive(:version).and_return false
      end

      it 'should not search further' do
        @bower.search

        expect(@bower).to have_received(:get_git_url).ordered
        expect(Sourcerer::Packages::Git).to_not have_received(:new)
        expect(@package).to_not have_received(:version)
      end
    end
  end
end
