#
# Sourcerer Namespace
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

  def self.install(package_name, version: :latest, type: :any)
    # search for package
    packages = Sourcerer::Package.search package_name, version: version, type: type

    if packages.length > 1
      package_types = packages.collect { |package| package.type.to_s }.join(', ')
      raise Sourcerer::Error.new 'sourcerer.install.multiple_packages_found', package_name: package_name, types: package_types
    else
      packages[0].install
    end
  end
end
