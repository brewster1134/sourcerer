RSpec.describe Sourcerer::Packages::Bower do
  before do
    @bower = Sourcerer::Packages::Bower.allocate
    @git_package = Sourcerer::Package.allocate
    @sourcerer = Sourcerer.allocate
  end

  describe '#search' do
    before do
      allow(Sourcerer).to receive(:new).and_return @sourcerer
      allow(@sourcerer).to receive(:package).and_return(@git_package)
      allow(@git_package).to receive(:install)
    end

    after do
      allow(Sourcerer).to receive(:new).and_call_original
    end

    context 'when package is found' do
      before do
        allow(@bower).to receive(:get_git_url).and_return 'url.git'
        allow(@git_package).to receive(:version).and_return true

        @return = @bower.search
      end

      it 'should search the underlying bower source url for a package' do
        expect(@bower).to have_received(:get_git_url).ordered
        expect(Sourcerer).to have_received(:new).with(Hash).ordered
        expect(@git_package).to have_received(:version).ordered
        expect(@git_package).to have_received(:install).ordered

        expect(@return).to eq true
      end
    end

    context 'when package is not found' do
      before do
        allow(@bower).to receive(:get_git_url).and_return nil
        allow(@git_package).to receive(:version).and_return false

        @return = @bower.search
      end

      it 'should not search further' do
        expect(@bower).to have_received(:get_git_url).ordered
        expect(Sourcerer).to_not have_received(:new)
        expect(@git_package).to_not have_received(:version)
        expect(@git_package).to_not have_received(:install)

        expect(@return).to eq false
      end
    end
  end

  describe '#get_git_url' do
    after do
      allow(RestClient). to receive(:get).and_call_original
    end

    context 'if url is found' do
      it 'should retutn the git path url' do
        allow(RestClient). to receive(:get).and_return('{ "url": "foo.com" }')

        expect(@bower.send(:get_git_url,  name: 'foo')).to eq 'foo.com'
      end
    end

    context 'if url is not found' do
      it 'should retutn nil' do
        allow(RestClient). to receive(:get).and_return('')

        expect(@bower.send(:get_git_url,  name: 'foo')).to eq nil
      end
    end
  end
end
