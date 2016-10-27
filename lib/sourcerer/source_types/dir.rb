#
# Sourcerer::SourceTypeDir
# Handler for directory sources
#
class Sourcerer::SourceType::Dir < Sourcerer::SourceType
  def move source, destination, _options
    FileUtils.cp_r "#{source}/.", destination
  end
end
