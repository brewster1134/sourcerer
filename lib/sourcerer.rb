#
# Sourcerer
# Namespace & API Entrypoint
# lib/sourcerer.rb
#
require 'active_support/core_ext/hash/keys'
require 'i18n'
require 'semantic'

# I18N
I18n.load_path += Dir[File.join('i18n', '*.yml')]
I18n.reload!
I18n.locale = ENV['LANG'].split('.').first.downcase

module Sourcerer
  require 'sourcerer/error'
  require 'sourcerer/meta'
  require 'sourcerer/version'
  require 'sourcerer/package'

  # Default Configuration
  DEFAULT_CACHE_DIRECTORY = '/Library/Caches/sourcerer'
  DEFAULT_PACKAGES_DIRECTORY = 'sourcerer_packages'
  DEFAULT_DESTINATION_DIRECTORY = File.join(Dir.pwd, DEFAULT_PACKAGES_DIRECTORY)
  # matches semantic versions using a wildcard or pessimistic operator
  SEMANTIC_VERSION_WILDCARD_REGEX = /^[><=~\s]{0,3}[0-9\.]{1,5}[a-z0-9+-\.]*$/
  # captures the integer artifacts from a semantic version wildcard
  SEMANTIC_VERSION_ARTIFACT_REGEX = /^([><=~]+)?\s?([0-9x]+)\.?([0-9x]+)?\.?([0-9x]+)?\-?([a-z]+)?\.?([0-9x]+)?\.?([0-9x]+)?\.?([0-9x]+)?\.?\-?(.+)?$/
  SEMANTIC_VERSION_OPERATORS = ['==', '<', '<=', '>', '>=', '~', '~>']

  # Entrypoint for Sourcerer via Ruby
  #
  def self.install package_name, version: :latest, type: :any, destination: DEFAULT_DESTINATION_DIRECTORY
    # search for package
    packages = Sourcerer::Package.search package_name: package_name, version: version, type: type.to_sym

    # if a single package is found, continue
    if packages[:success].length == 1
      package = packages[:success].first

    # if multiple packages are found, raise an error
    elsif packages[:success].length > 1
      package_types = packages[:success].collect { |package| package.type.to_s }.join(', ')
      raise Sourcerer::Error.new 'sourcerer.install.multiple_packages_found', package_name: package_name, package_types: package_types

    # if no packages are found, show errors and raise an exception
    elsif packages[:success].length == 0
      # show errors from each attempted package type search
      packages[:fail].each do |package|
        package.errors.each do |error|
          S.ay error.message, preset: :sourcerer_error
        end
      end

      raise Sourcerer::Error.new 'sourcerer.install.no_package_found', package_name: package_name
    end

    # install package
    package.install destination: destination
  end
end
