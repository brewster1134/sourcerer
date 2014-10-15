require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/reverse_merge'
require 'tmpdir'

class Sourcerer
  require 'sourcerer/interpolate'
  require 'sourcerer/source_type'

  # requre all source types
  Dir['source_types/*.rb'].each { |file| require file }

  attr_reader :source, :destination, :type, :interpolation_data

  # pass method through to source type
  def files *args; @type.files *args; end

private

    def initialize source, destination = nil, interpolation_data = {}
      @source = source
      @destination = File.expand_path(destination || ::Dir.mktmpdir)
      @type = init_source_type detect_type
      @interpolation_data = interpolation_data
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
      when /^[A-Za-z0-9-]+\/[A-Za-z0-9\-_.]+$/
        :git

      else
        raise Exception, "No type could be detected from `#{@source}`\nPlease make sure it is a valid directory or matches one of the supported source types."
      end
    end
end
