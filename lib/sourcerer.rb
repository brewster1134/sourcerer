#
# Sourcerer
# Namespace & API Entrypoint
# lib/sourcerer.rb
#
require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'i18n'
require 'json'
require 'rest-client'
require 'semantic'

# Cli Miami
CliMiami.set_preset :sourcerer_success, color: :green
CliMiami.set_preset :sourcerer_pending, color: :yellow
CliMiami.set_preset :sourcerer_error, color: :red

# I18N
I18n.load_path += Dir[File.join('i18n', '*.yml')]
I18n.reload!
I18n.locale = ENV['LANG'].split('.').first.downcase

class Sourcerer
  require 'sourcerer/error'
  require 'sourcerer/meta'
  require 'sourcerer/version'
  require 'sourcerer/package'

  # default configuration
  DEFAULT_CACHE_DIRECTORY = '/Library/Caches/sourcerer'
  DEFAULT_CLI = false
  DEFAULT_DESTINATION = File.join(Dir.pwd, 'sourcerer_packages')
  DEFAULT_FORCE = false
  DEFAULT_TYPE = :any
  DEFAULT_VERSION = :latest

  # semantic version configuration
  SEMANTIC_VERSION_OPERATORS = ['<', '<=', '>', '>=', '~', '~>']
  # matches semantic versions using a wildcard or pessimistic operator
  SEMANTIC_VERSION_WILDCARD_REGEX = /^[><=~\s]{0,3}[0-9\.]{1,5}[a-z0-9+-\.]*$/
  # captures the integer artifacts from a semantic version wildcard
  SEMANTIC_VERSION_ARTIFACT_REGEX = /^([><=~]+)?\s?([0-9x]+)\.?([0-9x]+)?\.?([0-9x]+)?\-?([a-z]+)?\.?([0-9x]+)?\.?([0-9x]+)?\.?([0-9x]+)?\.?\-?(.+)?$/

  # Entrypoint for Sourcerer
  #
  # @param name [String]  Name of a package to install
  # @param cli  [Boolean] If Sourcerer is being run from a command line binary
  # @param destination  [String]  A local directory to install the package to
  # @param force  [Boolean] Download package even if it is already cached
  # @param type [Symbol, Array<Symbol>]  Name of 1 or more supported package types
  # @param version  [String, :latest] Available version, tag, or meta data for the given package
  #
  def self.install name, cli: DEFAULT_CLI, destination: DEFAULT_DESTINATION, force: DEFAULT_FORCE, type: DEFAULT_TYPE, version: DEFAULT_VERSION
    self.new name: name, cli: cli, destination: destination, force: force, type: type, version: version
  end

  private

  def initialize name:, cli:, destination:, force:, type:, version:
    destination = File.expand_path destination
    packages = Sourcerer::Package.search name: name, version: version, type: type

    case packages[:success].length
    when 0
      type_string = type.is_a?(Array) ? type.join(', ') : type.to_s
      err = Sourcerer::Error.new 'initialize.no_package_found', name: name, type: type_string

      if cli
        err.print
        print_package_errors packages[:fail]
      else
        print_package_errors packages[:fail]
        raise err
      end
    when 1
      package = packages[:success].first
      package.install name: name, version: version, destination: destination, force: force
    else
      types = packages[:success].collect { |package| package.type.to_s }.join(', ')
      err = Sourcerer::Error.new 'initialize.multiple_packages_found', name: name, version: version, types: types

      if cli
        err.print
        package = prompt_for_package packages[:success]
        package.install name: name, version: version, destination: destination, force: force
      else
        raise err
      end
    end
  end

  def print_package_errors failed_packages
    failed_packages.each do |package|
      package.errors.each do |error|
        error.print
      end
    end
  end
end
