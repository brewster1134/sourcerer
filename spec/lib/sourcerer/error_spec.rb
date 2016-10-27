describe Sourcerer::Error do
  before do
    @error_instance = Sourcerer::Error.allocate
  end

  describe '#initialize' do
    before do
      @error = @error_instance.send :initialize, 'foo.bar', foo: 'FOO', bar: 'BAR'
    end

    it 'should look up i18n values' do
      expect(@error).to eq 'This FOO is a BAR'
    end
  end
end
