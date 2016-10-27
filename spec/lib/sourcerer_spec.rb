describe Sourcerer do
  before do
    allow(Sourcerer::Core).to receive(:new)

    @sourcerer = Sourcerer.new 'source', 'destination', foo: 'foo'
  end

  after do
    allow(Sourcerer::Core).to receive(:new).and_call_original
  end

  it 'should allow .new on namespace' do
    expect(Sourcerer::Core).to have_received(:new).with 'source', 'destination', foo: 'foo'
  end
end
