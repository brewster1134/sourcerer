module Sourcerer
  class Package
    @@subclasses = {}
    #
    # PUBLIC CLASS METHODS
    #

    # Search for a package with the version & type(s) specified
    #
    # @param [Hash] options
    # @option options [String] :package_name A name of the package to search for
    # @option options [String] :version A specific version to search for
    # @option options [Symbol, Array<Symbol>] :type The type(s) of package to search for
    # @return [Array<Sourcerer::Package>] An array of packages that match the specified name, version & type
    #
    def self.search package_name:, version:, type:
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
      errors << Sourcerer::Error.new(i18n_keys, args)
    end

    # Orchestrate downloading, caching, and installing the package
    #
    def install
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
      @found = nil
      @name = package_name
      @type = type
      @version = Semantic::Version.new(version) rescue version
      @source = search package_name: @name, version: @version

      # If no source was found, add a generic error as the first error
      @errors.unshift(Sourcerer::Error.new('packages.no_package_found', package_name: @name, package_type: @type)) unless @source
    end

    # Search for the package source asset with the given package name & version
    # @note The search method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @param [Hash] options
    # @option options [String] :package_name
    # @option options [String, Semantic::Version] :version
    # @return [String] if a matching package source is found, return source path
    # @return [nil] if no matching package source if found, return nil
    #
    def search package_name:, version:
      raise Sourcerer::Error.new 'package.search.search_method_not_defined', package_type: self.type
    end

    # Download the package
    # @note The download method needs defined in the package type class in their respective packages/[TYPE].rb file
    # @return [Sourcerer::Package]
    # @raise [Sourcerer::Error] If the package can't be downloaded
    #
    def download source:, destination:
      raise Sourcerer::Error.new 'package.download.download_method_not_defined', package_type: self.type
    end
  end

  module Packages
    Dir[File.join(__dir__, 'package_types', '*.rb')].each { |file| require file }
  end
end
