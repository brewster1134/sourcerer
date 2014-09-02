describe Sourcerer::SourceType do
  before do
    class Sourcerer::Foo < Sourcerer::SourceType; end
  end

  it 'should initialize when inherited' do
    expect(Sourcerer.type).to be_a Sourcerer::Foo
  end
end
