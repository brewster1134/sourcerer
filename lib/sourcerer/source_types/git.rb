#
# Sourcerer::SourceTypeDir
# Handler for git repo sources
#
class Sourcerer::SourceType::Git < Sourcerer::SourceType
  require 'git'

  def move source, destination, _options
    # if git repo is remote
    unless ::Dir.exist? source
      # regex to match any repo url to only the usename and repo name
      # @example
      #   'https://github.com/brewster1134/sourcerer.git' #=> 'brewster1134/sourcerer'
      regex = %r{^(?:.*com[:\/])?([^.]+)(?:\.git)?$}
      username_repo = source.match(regex)[1]
      source = "https://github.com/#{username_repo}.git"
    end

    ::Git.clone source, destination
  end
end
