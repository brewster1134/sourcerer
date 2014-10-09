class Sourcerer
  require 'sourcerer/source_type'
  attr_reader :source, :destination
  @@types = {}

  # Called from source_type when a new source type is inherited
  #
  def self.addType klass
    type = klass.name.split('::').last.downcase.to_sym
    @@types[type] ||= klass
  end

  def self.source; @@source; end
  def self.destination; @@destination; end
  def type; @type; end

  def initialize source, destination = nil
    @@source = source
    @@destination = File.expand_path(destination || ::Dir.mktmpdir)

    # require the source type library
    @type = detect_type
    init_source_type
  end

private

    # TODO: build towards support similar to bower
    # http://bower.io/docs/api/#install
    #
    def detect_type
      # check if local directory that is not a git repo
      if ::Dir.exists?(File.expand_path(@@source)) && @@source.match(/\.git$/).nil?
        return :dir
      end

      case @@source
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
      end
    end

    def init_source_type
      require "sourcerer/source_types/#{@type}"
      @@types[@type].new
    end
end
