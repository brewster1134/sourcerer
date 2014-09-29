class Sourcerer::Zip < Sourcerer::SourceType
  require 'archive/zip'

  def initialize
    Archive::Zip.extract source, destination
  end
end
