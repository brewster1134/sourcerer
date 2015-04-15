require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/string/inflections'
require 'tmpdir'

class Sourcerer
  require 'sourcerer/source_type'

  attr_reader :source, :destination, :options, :type

  GIT_GITHUB_SHORTHAND_REGEX = /^[A-Za-z0-9-]+\/[A-Za-z0-9\-_.]+$/

  # pass method through to source type
  def files *args; @type.files *args; end

private

    def initialize source, options = {}
      @options = {
        :destination => nil,
        :subdirectory => nil
      }.deep_merge! options

      @source = source
      @destination = File.expand_path(@options[:destination] || ::Dir.mktmpdir)
      @type = init_source_type detect_type
    end

    def init_source_type type
      "Sourcerer::SourceType::#{type.to_s.classify}".constantize.new self
    end

    # TODO: build towards support similar to bower
    # http://bower.io/docs/api/#install
    #
    def detect_type
      # check if local directory that is not a git repo
      if ::Dir.exists?(File.expand_path(@source)) && @source.match(/\.git$/).nil?
        @source = File.expand_path(@source)
        return :dir
      end

      case @source
      # Check extensions first
      #
      # git repo
      when /.git$/
        :git

      # zip file
      when /.zip$/
        :zip

      # github shorthand
      when GIT_GITHUB_SHORTHAND_REGEX
        @source = "git@github.com:#{@source}.git"
        :git

      else
        raise Exception, "No type could be detected from `#{@source}`\nPlease make sure it is a valid directory or matches one of the supported source types."
      end
    end
end
