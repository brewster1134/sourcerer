module Sourcerer
  class Package
    include Sourcerer::Version
    @@subclasses = {}
    #
    # PUBLIC CLASS METHODS
    #

    # Search for a package with the version & type(s) specified
    # @param [Hash] options
    # @option options [String] name A name of the package to search for
    # @option options [String] version A specific version to search for
    # @option options [Symbol] type The type(s) of package to search for
    # @return [Hash] Hash of success and fail arrays of packages
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
          if package.exists
            packages[:success] << package
          else
            packages[:fail] << package
          end
        end

      # search all package types
      elsif type.to_sym == :any
        subclasses.each do |subclass_type, subclass|
          package = subclass.new name: name, version: version, type: subclass_type
          if package.exists
            packages[:success] << package
          else
            packages[:fail] << package
          end
        end

      # search single package type
      else
        subclass = subclasses[type]
        package = subclass.new name: name, version: version, type: type
        if package.exists
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
    attr_reader :errors, :name, :source, :type, :version, :exists, :destination

    # Register a package error
    #
    def add_error i18n_keys, args = {}
      error = Sourcerer::Error.new("package.#{i18n_keys}", args)
      if args[:prepend]
        errors.unshift error
      else
        errors << error
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
        add_error 'download_failed', prepend: true, name: name, package_version: version
        return false
      end

      FileUtils.cp_r "#{cache_destination_path}/.", destination
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
    # @option options [String] name A name of the package to search for
    # @option options [String] version A specific version to search for
    # @option options [Symbol] type The package type being initialized
    # @return [True, False] if package and version both exist
    #
    def initialize name:, version:, type:
      @errors = []
      @exists = false
      @name = name
      @type = type.to_sym

      # If no source was found, add a generic error as the first error
      unless search
        add_error 'search_failed', prepend: true, name: @name, package_type: @type
        return
      end

      @version = find_matching_version version: version, versions_array: versions
      unless @version
        add_error 'version_failed', prepend: true, name: @name, package_version: version
        return
      end

      @exists = !!@version
    end

    # Download the package
    # @note The download method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @return [True, False] Boolean depending on if the download succeeds or fails
    #
    def download to:
      raise Sourcerer::Error.new 'package.method_not_defined', method_name: 'download', package_type: self.type
    end

    # Verify the package exists for the given package type & ignoring the version
    # @note The search method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @return [True, False] Boolean depending if the package is found or not
    #
    def search
      raise Sourcerer::Error.new 'package.method_not_defined', method_name: 'search', package_type: self.type
    end

    # Return a list of all available versions/tags for a given package
    # @note The versions method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @return [Array] An array of all available package versions or tags to choose from
    #
    def versions
      raise Sourcerer::Error.new 'package.method_not_defined', method_name: 'versions', package_type: self.type
    end
  end

  # Require all the package types
  #
  module Packages
    Dir[File.join(__dir__, 'package_types', '*.rb')].each { |file| require file }
  end
end
