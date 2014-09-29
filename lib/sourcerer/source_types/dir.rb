class Sourcerer::Dir < Sourcerer::SourceType
  def initialize
    FileUtils.cp_r "#{source}/.", destination
  end
end
