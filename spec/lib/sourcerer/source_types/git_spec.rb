describe Sourcerer::SourceType::Git do
  @repo_formats = [
    'https://github.com/brewster1134/sourcerer.git',
    'https://github.com/brewster1134/sourcerer',
    'git@github.com:brewster1134/sourcerer.git',
    'brewster1134/sourcerer'
  ]

  before do
    @source_type = Sourcerer::SourceType::Git.allocate
  end

  after do
    allow(Git).to receive(:clone).and_call_original
  end

  @repo_formats.each do |repo|
    it 'should handle different remote repo formats' do
      allow(Git).to receive(:clone)

      @source_type.move repo, 'destination', {}

      expect(Git).to have_received(:clone).with('https://github.com/brewster1134/sourcerer.git', 'destination')
    end
  end
end
