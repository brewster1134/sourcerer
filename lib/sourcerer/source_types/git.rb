class Sourcerer::Git < Sourcerer::SourceType
  require 'git'

  def initialize
    Git.clone source, destination
  end
end
