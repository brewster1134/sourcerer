class Sourcerer::SourceType::Git < Sourcerer::SourceType
  require 'git'

  def move
    ::Git.clone @source, @destination
  end
end
