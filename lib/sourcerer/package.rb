module Sourcerer
  class Package
    include Sourcerer::Version
    @@subclasses = {}
    #
    # PUBLIC CLASS METHODS
    #

    # Search for a package with the version & type(s) specified
    #
    # @param name [String] A package name to search for
    # @param version [String] Criteria to filter by
    # @param type [Symbol, Array] The type(s) of package to search for
    # @return [Hash] Hash of initialized packages, separated by success/fail
    # @example
    #   {
    #     success: [ SUCCESSFUL SOURCERER::PACKAGE INSTANCE ],
    #     fail: [ FAILED SOURCERER::PACKAGE INSTANCE ]
    #   }
    #
    def self.search name:, version:, type: :any
      packages = {
        success: [],
        fail: []
      }

      # search multiple package types
      if type.is_a? Array
        type.each do |t|
          subclass = subclasses[t]

          package = subclass.new name: name, version: version, type: t
          if package.version
            packages[:success] << package
          else
            packages[:fail] << package
          end
        end

      # search all package types
      elsif type.to_sym == :any
        subclasses.each do |subclass_type, subclass|
          package = subclass.new name: name, version: version, type: subclass_type
          if package.version
            packages[:success] << package
          else
            packages[:fail] << package
          end
        end

      # search single package type
      else
        subclass = subclasses[type]
        package = subclass.new name: name, version: version, type: type
        if package.version
          packages[:success] << package
        else
          packages[:fail] << package
        end
      end

      return packages
    end

    attr_reader :name, :version, :type

    # Register a package error
    # @param i18n_keys [String] A dot separated string of keys that match the i18n yaml structure
    # @param [Hash] args Options to be passed through to the new error instance
    #
    def add_error i18n_keys, **args
      called_from_type = self.class.name != 'Sourcerer::Package'

      i18n_keys_array = ['package', i18n_keys]
      i18n_keys_array << type.to_s if called_from_type

      error = Sourcerer::Error.new(i18n_keys_array.join('.'), args)

      if called_from_type
        @errors << error
      else
        @errors.unshift error
      end
    end

    # Orchestrate downloading, caching, and installing the package
    #
    def install destination:, force:
      @destination = File.expand_path destination

      # create cache directory
      cache_destination_path = File.join(Sourcerer::DEFAULT_CACHE_DIRECTORY, name, version)
      FileUtils.mkdir_p cache_destination_path

      if force || Dir.glob("#{cache_destination_path}/*").empty?
        download to: cache_destination_path
      end

      if Dir.glob("#{cache_destination_path}/*").empty?
        add_error 'download.fail', name: name, version: version
        return false
      end

      FileUtils.cp_r "#{cache_destination_path}/.", @destination
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
    # @see Sourcerer::Package#search
    #
    def initialize name:, version:, type:
      @errors = []
      @name = name
      @type = type.to_sym

      # If no source was found, add a generic error as the first error
      unless search
        add_error 'search.fail', name: @name, type: @type
        return
      end

      @version = find_matching_version version: version, versions_array: versions
      unless @version
        add_error 'version.fail', name: @name, version: version
        return
      end
    end

    # Download the package
    # @note The download method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @param to [String] Final location for the downloaded package
    # @return [Boolean] If package version is downloaded to cache
    #
    def download to:
      raise Sourcerer::Error.new 'package.method_not_defined', method_name: 'download', type: self.type
    end

    # Check that a package exists
    # @note The search method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @return [Boolean] If the package is found
    #
    def search
      raise Sourcerer::Error.new 'package.method_not_defined', method_name: 'search', type: self.type
    end

    # Return a list of all available versions/tags for a given package
    # @note The versions method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @return [Array<String>] An array of all available package versions or tags
    #
    def versions
      raise Sourcerer::Error.new 'package.method_not_defined', method_name: 'versions', type: self.type
    end
  end

  # Require all the package types
  #
  module Packages
    Dir[File.join(__dir__, 'package_types', '*.rb')].each { |file| require file }
  end
end
