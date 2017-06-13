module Sourcerer
  class Package
    include Sourcerer::Version
    @@subclasses = {}
    #
    # PUBLIC CLASS METHODS
    #

    # Search for a package with the version & type(s) specified
    # @param [String] package_name A name of the package to search for
    # @param [String] version A specific version to search for
    # @param [Symbol, Array<Symbol>] type The type(s) of package to search for
    # @return [Hash] Object of success and failed packages
    #
    def self.search package_name:, version:, type: :any
      packages = {
        success: [],
        fail: []
      }

      # search multiple package types
      if type.is_a? Array
        type.each do |t|
          subclass = subclasses[t.to_sym]

          package = subclass.new package_name: package_name, version: version, type: t.to_sym
          if package.source
            packages[:success] << package
          else
            packages[:fail] << package
          end
        end

      # search all package types
      elsif type.to_sym == :any
        subclasses.each do |subclass_type, subclass|
          package = subclass.new package_name: package_name, version: version, type: subclass_type
          if package.source
            packages[:success] << package
          else
            packages[:fail] << package
          end
        end

      # search single package type
      else
        subclass = subclasses[type.to_sym]
        package = subclass.new package_name: package_name, version: version, type: type.to_sym
        if package.source
          packages[:success] << package
        else
          packages[:fail] << package
        end

      end

      return packages
    end

    #
    # PUBLIC INSTANCE METHODS
    #
    attr_reader :errors, :name, :source, :type, :version

    # Register a package error
    #
    def add_error i18n_keys, args = {}
      errors << Sourcerer::Error.new("packages.#{i18n_keys}", args)
    end

    # Orchestrate downloading, caching, and installing the package
    #
    def install destination:
      # create the root cache directory
      cache_dir = Sourcerer::DEFAULT_CACHE_DIRECTORY
      FileUtils.mkdir_p cache_dir

      # define the package cache directory
      cache_key = "#{source}_#{version.to_s}".downcase.gsub(/[^A-Za-z0-9_]/, '')
      cache_package_dir = File.join(cache_dir, cache_key)

      # define the package destination directory
      package_destination_dir = "#{destination}/#{name}"

      # if cache dir does not exist or is empty, create it and pass it to the package type download method
      unless File.directory?(cache_package_dir) && Dir.entries(cache_package_dir).length > 2
        FileUtils.mkdir_p cache_package_dir
        download source: source, destination: cache_package_dir
      end

      # cache directory should exist and contain the package
      FileUtils.mkdir_p package_destination_dir
      FileUtils.cp_r "#{cache_package_dir}/.", package_destination_dir
    end

    private

    #
    # PRIVATE CLASS METHODS
    #
    def self.inherited subclass
      key = caller.first.match(/.+\/(.+)\.rb/)[1].to_sym
      add_subclass key, subclass
    end

    def self.add_subclass key, subclass
      @@subclasses[key] = subclass
    end

    def self.subclasses key = nil
      key ? @@subclasses[key] : @@subclasses
    end

    #
    # PRIVATE INSTANCE METHODS
    #

    # Create a new package instance and search for a matching version
    # @param [Hash] options
    # @option options [String] :package_name A name of the package to search for
    # @option options [String] :version A specific version to search for
    # @option options [Symbol] :type The package type being initialized
    #
    def initialize package_name:, version:, type:
      @errors = []
      @name = package_name
      @type = type
      @version = Semantic::Version.new(version) rescue version
      @source = search package_name: @name, version: @version

      # If no source was found, add a generic error as the first error
      @errors.unshift(Sourcerer::Error.new('packages.no_package_found', package_name: @name, package_type: @type)) unless @source
    end

    # Download the package
    # @note The download method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @param [Hash] options
    # @option options [String] :source The source string returned from the #search
    # @option options [String, Semantic::Version] :destination The path to a cached directory to download to, or copy from
    # @return [Pathname] If the download completes, returns the path to the the cached directory
    # @raise [false] If the download fails, returns false
    #
    def download source:, destination:
      raise Sourcerer::Error.new 'package.download.download_method_not_defined', package_type: self.type
    end

    # Search for the package source asset with the given package name & version
    # @note The search method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @param [Hash] options
    # @option options [String] :package_name
    # @option options [String, Semantic::Version] :version
    # @return [String] If a matching package source is found, returns source path
    # @return [false] If no matching package source if found, returns false
    #
    def search package_name:, version:
      raise Sourcerer::Error.new 'package.search.search_method_not_defined', package_type: self.type
    end

    # Return a list of all available versions/tags for a given package
    # @note The versions method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @param [Hash] options
    # @option options [String] :package_name
    # @return [Array] An array of all available package versions or tags to filter
    #
    def versions package_name:
      raise Sourcerer::Error.new 'package.versions.versions_method_not_defined', package_type: self.type
    end
  end

  # Require all the package types
  #
  module Packages
    Dir[File.join(__dir__, 'package_types', '*.rb')].each { |file| require file }
  end
end
