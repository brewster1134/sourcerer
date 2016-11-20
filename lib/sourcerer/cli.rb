require 'cli_miami'
require 'thor'

module Sourcerer
  class Cli < Thor
    default_task :install

    desc 'install [PACKAGE]', I18n.t('sourcerer.cli.install.description')
    option :version, aliases: '-v', default: :latest, desc: I18n.t('sourcerer.cli.install.options.version.description')
    option :type, aliases: '-t', default: :any, desc: I18n.t('sourcerer.cli.install.options.type.description')
    option :destination, aliases: '-d', default: File.join(Dir.pwd, 'sourcerer_packages'), desc: I18n.t('sourcerer.cli.install.options.destination.description')
    def install package_name
      # search for package
      packages = Sourcerer::Package.search package_name, version: options[:version], type: options[:type]

      # prompt user to choose a package if multiple are found
      package = if packages.length > 1
        packages_hash = Hash[packages.collect{ |package| [package.type, package] }]
        selected_package = A.sk I18n.t('sourcerer.cli.install.multiple_packages_found', package: package_name.green), type: :multiple_choice, choices: packages_hash, max: 1
        selected_package.values[0]
      else
        packages[0]
      end

      # install the package
      S.ay I18n.t('sourcerer.cli.install.installing_package', package: package_name.green, type: package.type.green, destination: options[:destination].green)
      package.install
    end

    desc 'help [COMMAND]', I18n.t('sourcerer.cli.help.description')
    def help command = nil
      super
    end
  end
end
