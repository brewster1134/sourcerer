module Sourcerer
  class Package
    @@subclasses = {}
    #
    # PUBLIC CLASS METHODS
    #
    def self.search package_name:, version:, type:
      packages = []

      # search all package types
      if type == :any
        subclasses.each do |subclass_type, subclass|
          package = subclass.new package_name: package_name, version: version, type: subclass_type
          packages << package if package.found?
        end

        raise Sourcerer::Error.new 'package.search.any_type.no_packages_found', package_name: package_name, version: version if packages.empty?

      # search single package type
      else
        subclass = subclasses[type.to_sym]
        package = subclass.new package_name: package_name, version: version, type: type.to_sym
        if package.found?
          packages << package
        else
          raise Sourcerer::Error.new 'package.search.single_type.no_package_found', package_name: package_name, version: version, type: type
        end
      end

      return packages
    end

    #
    # PUBLIC INSTANCE METHODS
    #
    attr_reader :type

    # Copies a downloaded package to the destination
    def copy destination:
      # FileUtils.cp_r source, destination
    end

    # Download method needs defined for each package type class in the respective packages/[TYPE].rb file
    #
    def download
      raise Sourcerer::Error.new 'package.download.download_method_not_defined', package_type: self.type
    end

    def search package_name:, version:
      raise Sourcerer::Error.new 'package.search.search_method_not_defined', package_type: self.type
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
    attr_writer :found

    def initialize package_name:, version:, type:
      @package_name = package_name
      @version = Semantic::Version.new(version) rescue version
      @type = type.to_sym
      @package = search package_name: @package_name, version: @version
      @found = !!@package
    end

    def found?
      @found
    end
  end

  module Packages
    Dir[File.join(__dir__, 'packages', '*.rb')].each { |file| require file }
  end
end
