require 'active_support/inflector'
require 'open-uri'

class Sourcerer
  attr_reader :dest_dir, :source, :tmp_dir, :type

  def initialize source, dest = nil
    @type = detect_type source
    @source = source
    @tmp_dir = ::Dir.mktmpdir
    @dest_dir = dest || @tmp_dir

    # find the right source type and require and initialize it
    initialize_source_type @type
  end

  def files glob = '**/*'
  end

private

    def detect_type source
      # check if local directory that is not a git repo
      if ::Dir.exists?(File.expand_path(source)) && source.match(/\.git$/).nil?
        return :dir
      end

      case source
      # Check extensions first
      #
      # git repo
      when /.git$/
        :git

      # zip file
      when /.zip$/
        :zip

      # Check special cases
      #
      # github shorthand
      when /^[A-Za-z0-9-]+\/[A-Za-z0-9\-_.]+$/
        :git
      end
    end

    def initialize_source_type type
      require "source_types/#{type}"
      "Sourcerer::#{type.to_s.classify}".constantize.new @source
    end
end
