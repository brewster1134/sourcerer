require 'active_support/inflector'
require 'open-uri'

class Sourcerer
  require 'source_type'
  attr_reader :dest_dir, :source, :tmp_dir

  #
  def self.type= type; @type = type; end
  def self.type; @type; end

  def initialize source, dest = nil
    @source = source
    @tmp_dir = ::Dir.mktmpdir
    @dest_dir = dest || @tmp_dir

    # require the source type library
    type = detect_type
    require_source_type type
  end

  def files glob = '**/*'
  end

private

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

      # Check special cases
      #
      # github shorthand
      when /^[A-Za-z0-9-]+\/[A-Za-z0-9\-_.]+$/
        :git
      end
    end

    def require_source_type type
      require "source_types/#{type}"
    end
end
