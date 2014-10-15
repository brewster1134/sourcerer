require 'spec_helper'
require 'tmpdir'

class InterpolateSpec
  include Sourcerer::Interpolate
  attr_reader :source, :destination, :interpolation_data
  def initialize
    @source = 'spec/fixtures/interpolate'
    @destination = ::Dir.mktmpdir
    @interpolation_data = { foo: { :bar => :baz }}
  end
end

describe Sourcerer::Interpolate do
  before do
    @interpolate = InterpolateSpec.new
    FileUtils.cp_r @interpolate.source, @interpolate.destination
    @interpolate.interpolate
  end

  it 'should process and rename .erb files' do
    expect(File.read(File.join(@interpolate.destination, 'interpolate', 'baz', 'baz.txt'))).to include 'baz'
  end

  it 'should create dot notation accessible options' do
    expect(@interpolate.send(:data).foo.bar).to eq :baz
  end
end
