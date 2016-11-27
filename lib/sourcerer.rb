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
  require 'sourcerer/package'

  # Default Configuration
  DEFAULT_PACKAGES_DIRECTORY = 'sourcerer_packages'
  DEFAULT_DESTINATION_DIRECTORY = File.join(Dir.pwd, DEFAULT_PACKAGES_DIRECTORY)

  # Entrypoint for Sourcerer via Ruby
  #
  def self.install package_name, version: :latest, type: :any, destination: DEFAULT_DESTINATION_DIRECTORY
    # search for package
    packages = Sourcerer::Package.search package_name: package_name, version: version, type: type

    # if a single package is found, continue
    if packages.length == 1
      package = packages.first

    # if multiple packages are found, raise an error
    elsif packages.length > 1
      package_types = packages.collect { |package| package.type.to_s }.join(', ')
      raise Sourcerer::Error.new 'sourcerer.install.multiple_packages_found', package_name: package_name, package_types: package_types

    # if no packages are found, raise an error
    elsif packages.length == 0
      raise Sourcerer::Error.new 'sourcerer.install.no_package_found', package_name: package_name
    end

    # download & install package
    package.download
    package.copy destination: destination
  end
end
