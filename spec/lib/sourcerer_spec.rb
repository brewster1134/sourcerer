describe Sourcerer do
  it 'should allow calling new on root namespace' do
    allow(Sourcerer::Core).to receive(:new)

    Sourcerer.new 'source', 'destination', foo: 'foo'

    expect(Sourcerer::Core).to have_received(:new).with 'source', 'destination', foo: 'foo'
  end
end
