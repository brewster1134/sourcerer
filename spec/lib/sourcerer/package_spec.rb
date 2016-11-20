RSpec.describe Sourcerer::Package do
  describe '.search' do
    before do
      @package = Sourcerer::Package.allocate

      allow(@package).to receive(:search)
      allow(Sourcerer::Packages::Bower).to receive(:new).and_return @package
      allow(Sourcerer::Packages::Gem).to receive(:new).and_return @package
      allow(Sourcerer::Packages::Git).to receive(:new).and_return @package
      allow(Sourcerer::Packages::Local).to receive(:new).and_return @package
      allow(Sourcerer::Packages::Npm).to receive(:new).and_return @package
      allow(Sourcerer::Packages::Url).to receive(:new).and_return @package
    end

    context 'when searching any type' do
      before do
        Sourcerer::Package.search 'package_foo', version: '1.2.3', type: :any
      end

      it 'should search each package type' do
        expect(Sourcerer::Packages::Bower).to have_received(:new).with('package_foo', version: '1.2.3')
        expect(Sourcerer::Packages::Gem).to have_received(:new).with('package_foo', version: '1.2.3')
        expect(Sourcerer::Packages::Git).to have_received(:new).with('package_foo', version: '1.2.3')
        expect(Sourcerer::Packages::Local).to have_received(:new).with('package_foo', version: '1.2.3')
        expect(Sourcerer::Packages::Npm).to have_received(:new).with('package_foo', version: '1.2.3')
        expect(Sourcerer::Packages::Url).to have_received(:new).with('package_foo', version: '1.2.3')

        expect(@package).to have_received(:search).with('package_foo', version: '1.2.3').exactly(6).times
      end
    end

    context 'when searching a specific type' do
      before do
        Sourcerer::Package.search 'package_foo', version: '1.2.3', type: 'git'
      end

      it 'should search only the specific package type' do
        expect(Sourcerer::Packages::Bower).to_not have_received(:new)
        expect(Sourcerer::Packages::Gem).to_not have_received(:new)
        expect(Sourcerer::Packages::Git).to have_received(:new).with('package_foo', version: '1.2.3')
        expect(Sourcerer::Packages::Local).to_not have_received(:new)
        expect(Sourcerer::Packages::Npm).to_not have_received(:new)
        expect(Sourcerer::Packages::Url).to_not have_received(:new)

        expect(@package).to have_received(:search).with('package_foo', version: '1.2.3').exactly(1).times
      end
    end

    it 'should return an array of packages' do
      packages = Sourcerer::Package.search 'package_foo', version: '1.2.3', type: 'git'
      expect(packages).to eq [@package]
    end
  end
end
