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
  DEFAULT_FILE_SYSTEM_SAFE_SUB = /[\s\']/
  DEFAULT_FORCE = false
  DEFAULT_TYPE = :any
  DEFAULT_VERSION = :latest

  # supported semantic version operators
  SEMVER_OPERATORS = ['<', '<=', '>', '>=', '~', '~>']
  # captures the artifacts needed to create a complete semantic version from a partial one
  SEMVER_ARTIFACT_REGEX = /^([#{SEMVER_OPERATORS.join.split(//).uniq.join}]+)?\s?([0-9]+)\.?([0-9x]+)?\.?([0-9x]+)?\-?([0-9A-Za-z-]+)?\.?([0-9]+)?\.?([0-9x]+)?\.?([0-9x]+)?(.+)?$/
  # matches a valid semantic version
  SEMVER_COMPLETE_REGEX = /([0-9]+\.[0-9]+\.[0-9]+[0-9A-Za-z\+\-\.]*)/
  # matches a partial semantic version with a wildcard or operator
  SEMVER_PARTIAL_REGEX = /^([#{SEMVER_OPERATORS.join.split(//).uniq.join}]+)?\s?\d+([\d\.x]+)?/

  # Entrypoint for Sourcerer
  #
  # @param name [String] Name of a package to install
  # @param cli [Boolean] If Sourcerer is being run from a command line binary
  # @param destination [String] A local directory to install the package to
  # @param force [Boolean] Download package even if it is already cached
  # @param type [#to_sym] A supported type
  # @param version [String, :latest] Available version, tag, or meta data for the given package
  #
  def self.install name, cli: DEFAULT_CLI, destination: DEFAULT_DESTINATION, force: DEFAULT_FORCE, type: DEFAULT_TYPE, version: DEFAULT_VERSION
    self.new cli: cli, destination: destination, force: force, name: name, type: type, version: version
  end

  attr_reader :package

  private

  def initialize **options
    Sourcerer::Error.cli = options[:cli]

    packages = Sourcerer::Package.search options

    @package = get_package packages, options
    @package.install
  rescue Sourcerer::Error => e
    e.print
  end

  def get_package packages, **options
    case packages[:success].length
    when 0
      print_package_errors packages[:fail], true
      raise Sourcerer::Error.new('get_package.no_package_found', name: options[:name], type: options[:type], version: options[:version])
    when 1
      return packages[:success].first
    else
      types = packages[:success].collect { |package| package.type.to_s }.join(', ')
      e = Sourcerer::Error.new('get_package.multiple_packages_found', name: options[:name], version: options[:version], types: types)
      e.print

      return prompt_for_package packages[:success] if options[:cli]
      raise e
    end
  end

  def print_package_errors packages, cli
    packages.each do |package|
      package.errors.each do |e|
        e.print
      end
    end
  end
end
