RSpec.describe Sourcerer::Packages::Bower do
  describe '#search' do
    before do
      @bower = Sourcerer::Packages::Bower.allocate
      @package = Sourcerer::Package.allocate

      allow(@bower).to receive(:get_url)
      allow(Sourcerer::Package).to receive(:search)
    end

    context 'when package is found' do
      before do
        allow(@bower).to receive(:get_url).and_return 'bower_package_url'
        allow(@package).to receive(:source).and_return 'bower_package_git_url'
        allow(Sourcerer::Package).to receive(:search).and_return [@package]

        @bower_search = @bower.search package_name: 'bower_package', version: '1.2.3'
      end

      it 'should search for the package in the right order' do
        expect(@bower).to have_received(:get_url).with('bower_package').ordered
        expect(Sourcerer::Package).to have_received(:search).with({ package_name: 'bower_package', version: '1.2.3', type: [:git, :url] }).ordered
        expect(@package).to have_received(:source).ordered
      end

      it 'should return the source' do
        expect(@bower_search).to eq 'bower_package_git_url'
      end
    end

    context 'when package is not found' do
      before do
        allow(@bower).to receive(:get_url).and_return nil

        @bower_search = @bower.search package_name: 'bower_package', version: '1.2.3'
      end

      it 'should return false' do
        expect(@bower).to have_received(:get_url).with 'bower_package'
        expect(Sourcerer::Package).to_not have_received :search
        expect(@bower_search).to eq false
      end
    end

    context 'when package url is not found' do
      before do
        allow(@bower).to receive(:get_url).and_return 'bower_package_url'
        allow(Sourcerer::Package).to receive(:search).and_return []

        @bower_search = @bower.search package_name: 'bower_package', version: '1.2.3'
      end

      it 'should return false' do
        expect(@bower).to have_received(:get_url).with 'bower_package'
        expect(Sourcerer::Package).to have_received(:search).with({ package_name: 'bower_package', version: '1.2.3', type: [:git, :url] })
        expect(@bower_search).to eq false
      end
    end
  end

  describe '#download' do
  end
end
