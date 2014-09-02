class Sourcerer::SourceType
  def self.inherited klass
    Sourcerer.type = klass.new
  end
end
