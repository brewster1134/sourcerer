class Sourcerer::SourceType::Zip < Sourcerer::SourceType
  require 'archive/zip'

  def move
    Archive::Zip.extract @source, @destination
  end
end
