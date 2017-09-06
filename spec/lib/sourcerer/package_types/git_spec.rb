RSpec.describe Sourcerer::Packages::Git do
  before do
    @git_package = Sourcerer::Packages::Git.allocate
  end

  describe '#search' do
    before do
      allow(@git_package).to receive(:name).and_return 'brewster1134/sourcerer'

      expect(@git_package).to receive(:name).ordered
      expect(@git_package).to receive(:get_repo_source).with('brewster1134', 'sourcerer').ordered
    end

    context 'if git repo is found' do
      before do
        allow(@git_package).to receive(:get_repo_source).and_return true

        @git_search = @git_package.search
      end

      it 'should return true' do
        expect(@git_search).to eq true
      end
    end

    context 'if git repo is not found' do
      before do
        allow(@git_package).to receive(:get_repo_source).and_return false

        @git_search = @git_package.search
      end

      it 'should return true' do
        expect(@git_search).to eq false
      end
    end
  end
end
