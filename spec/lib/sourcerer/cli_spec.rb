RSpec.describe Sourcerer::Cli do
  before do
    @cli = Sourcerer::Cli.allocate
  end
  
  after do
    allow(A).to receive(:sk).and_call_original
    allow(Sourcerer::Package).to receive(:search).and_call_original
  end

  context 'when a single package is found' do
    before do
      @package = Sourcerer::Package.allocate
      
      allow(@package).to receive(:install)
      allow(@package).to receive(:location).and_return 'bower'
      allow(A).to receive(:sk)
      allow(Sourcerer::Package).to receive(:search).and_return [@package]
      
      @cli.options = { version: '1.2.3', source: 'bower', destination: 'packages' }
      @cli.install 'package_foo'
    end
    
    it 'should not prompt the user to choose a package' do
      expect(Sourcerer::Package).to have_received(:search).with('package_foo', version: '1.2.3', source: 'bower').ordered
      expect(A).to_not have_received(:sk)
      expect(@package).to have_received(:install).ordered
    end
  end
  
  context 'when multiple packages are found' do
    before do
      @package_one = Sourcerer::Package.allocate
      @package_two = Sourcerer::Package.allocate
      
      allow(@package_one).to receive(:install)
      allow(@package_one).to receive(:location).and_return 'bower'
      allow(@package_two).to receive(:location).and_return 'git'
      allow(A).to receive(:sk).and_return({ 'bower': @package_one })
      allow(Sourcerer::Package).to receive(:search).and_return [@package_one, @package_two]
      
      @cli.options = { version: '1.2.3', source: :any, destination: 'packages' }
      @cli.install 'package_foo'
    end

    it 'should prompt the user to choose a package' do
      expect(Sourcerer::Package).to have_received(:search).with('package_foo', version: '1.2.3', source: :any).ordered
      expect(A).to have_received(:sk).with('multiple_packages_found', hash_including(choices: { 'bower' => @package_one, 'git' => @package_two })).ordered
      expect(@package_one).to have_received(:install).ordered
    end
  end
end