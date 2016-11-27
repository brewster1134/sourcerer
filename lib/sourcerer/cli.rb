require 'cli_miami'
require 'thor'

module Sourcerer
  class Cli < Thor
    default_task :install

    desc 'install [PACKAGE NAME]', I18n.t('sourcerer.cli.install.description')
    option :version, aliases: '-v', default: :latest, desc: I18n.t('sourcerer.cli.install.options.version.description')
    option :type, aliases: '-t', default: :any, desc: I18n.t('sourcerer.cli.install.options.type.description')
    option :destination, aliases: '-d', default: File.join(Dir.pwd, 'sourcerer_packages'), desc: I18n.t('sourcerer.cli.install.options.destination.description')
    def install package_name
      # search for package
      packages = Sourcerer::Package.search package_name: package_name, version: options[:version], type: options[:type]

      # if a single package is found, continue
      if packages.length == 1
        package = packages.first

      # if multiple packages are found, prompt user to choose a package type
      elsif packages.length > 1
        packages_hash = Hash[packages.collect{ |package| [package.type, package] }]
        selected_package = A.sk I18n.t('sourcerer.cli.install.multiple_packages_found', package_name: package_name.green), type: :multiple_choice, choices: packages_hash, max: 1
        package = selected_package.values.first

      # if no packages are found, show user an error and exit
      elsif packages.length == 0
        S.ay I18n.t('sourcerer.cli.install.no_package_found', package_name: package_name), preset: :sourcerer_error
        return
      end

      # download & install package
      S.ay I18n.t('sourcerer.cli.install.installing_package', package_name: package_name.green, type: options[:type].to_s.green, destination: options[:destination].green), preset: :sourcerer_success
      package.download
      package.copy destination: options[:destination]

      S.ay I18n.t('sourcerer.cli.install.success'), preset: :sourcerer_success
    end

    desc 'help [COMMAND]', I18n.t('sourcerer.cli.help.description')
    def help command = nil
      super
    end
  end
end
