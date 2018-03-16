class Sourcerer
  class Package
    include Sourcerer::Version
    @@subclasses = {}
    #
    # PUBLIC CLASS METHODS
    #

    # Search for a package with the version & type(s) specified
    # @see Sourcerer.install
    # @return [Hash] Hash of initialized packages, separated by success & fail keys
    # @example
    #   {
    #     success: [ SUCCESSFUL SOURCERER::PACKAGE INSTANCE ],
    #     fail: [ FAILED SOURCERER::PACKAGE INSTANCE ]
    #   }
    #
    def self.search **options
      packages = {
        success: [],
        fail: []
      }

      if options[:type] == :any
        subclasses.each do |subclass_type, subclass|
          package = subclass.new(options)

          if package.version
            packages[:success] << package
          else
            packages[:fail] << package
          end
        end
      elsif subclass = subclasses[options[:type].to_sym]
        package = subclass.new(options)

        if package.version
          packages[:success] << package
        else
          packages[:fail] << package
        end
      else
        raise Sourcerer::Error.new('package.search.invalid_type', type: options[:type])
      end

      return packages
    end

    #
    # PUBLIC INSTANCE METHODS
    #

    attr_reader :cli, :destination, :force, :name, :type, :version

    # Orchestrate downloading, caching, and installing the package
    #
    def install
      # run the pre-installation hook
      pre_install if respond_to? :pre_install

      # create cache directory
      cache_dir = File.join(Sourcerer::DEFAULT_CACHE_DIRECTORY, name.gsub(Sourcerer::DEFAULT_FILE_SYSTEM_SAFE_SUB, '_'), version.to_s.gsub(Sourcerer::DEFAULT_FILE_SYSTEM_SAFE_SUB, '_'))
      cache_contents = ->{ Dir.glob("#{cache_dir}/*") }

      if force || cache_contents.call.empty?
        FileUtils.mkdir_p cache_dir
        download to: cache_dir
      end

      if cache_contents.call.empty?
        raise Sourcerer::Error.new 'install.download_fail', name: name, version: version.to_s
      end

      destination_dir = File.join(destination, name, version.to_s)
      FileUtils.mkdir_p destination_dir

      FileUtils.cp_r "#{cache_dir}/.", destination_dir

    rescue Sourcerer::Error => e
      e.print
    end

    private

    #
    # PRIVATE CLASS METHODS
    #
    def self.inherited subclass
      key = caller.first.match(/.+\/(.+)\.rb/)[1].to_sym
      subclass.class_variable_set :@@type, key
      @@subclasses[key] = subclass
    end

    def self.subclasses key = nil
      key ? @@subclasses[key] : @@subclasses
    end

    #
    # PRIVATE INSTANCE METHODS
    #

    # Create a new package instance and search for a matching version
    # @see Sourcerer::Package#search
    #
    def initialize **options
      @cli = options[:cli]
      @destination = File.expand_path options[:destination]
      @errors = []
      @force = options[:force]
      @name = options[:name]
      @type = self.class.class_variable_get(:@@type)

      # call type search method
      search

      # find version that matches criteria
      @version = find_matching_version version: options[:version], versions_array: versions
    end

    def download_tar url:, to:
      # download and extract
      response = RestClient.get(url)
      tmp_file = Tempfile.new
      File.write(tmp_file.path, response.to_s)
      `tar -x -f #{tmp_file.path} -C #{to} --strip 1`
    end

    # Download the package
    # @note The download method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @param to [String] Final location for the downloaded package
    # @return [Boolean] If package version is downloaded to cache
    #
    def download to:
      raise Sourcerer::Error.new 'method_not_defined', method_name: 'download', type: type
    end

    # Check that a package exists
    # @note The search method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @return [Boolean] If the package is found
    #
    def search
      raise Sourcerer::Error.new 'method_not_defined', method_name: 'search', type: type
    end

    # Return a list of all available versions/tags for a given package
    # @note The versions method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @return [Array<String>] An array of all available package versions or tags
    #
    def versions
      raise Sourcerer::Error.new 'method_not_defined', method_name: 'versions', type: type
    end

    # Return a list of all available versions/tags for a given package
    # @note The latest method can be also defined in the package type class in their respective packages/[TYPE].rb file
    # @return [String] If not defined, the first available version will be considered the latest
    #
    def latest
      versions.first
    end
  end

  # Require all the package types
  #
  module Packages
    Dir[File.join(__dir__, 'package_types', '*.rb')].each { |file| require file }
  end
end
