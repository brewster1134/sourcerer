class Sourcerer::SourceType::Git < Sourcerer::SourceType
  require 'git'

  def move
    set_git_source

    ::Git.clone @source, @destination
  end

  def set_git_source
    @source = "git@github.com:#{@source}.git" if @source =~ Sourcerer::GIT_GITHUB_SHORTHAND_REGEX
  end
end
