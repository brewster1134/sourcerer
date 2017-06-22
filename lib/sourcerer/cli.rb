require 'cli_miami'
require 'thor'

CliMiami.set_preset :sourcerer_success, color: :green
CliMiami.set_preset :sourcerer_pending, color: :yellow
CliMiami.set_preset :sourcerer_error, color: :red

module Sourcerer
  class Cli < Thor
    default_task :install

    desc 'install [PACKAGE NAME]', I18n.t('sourcerer.cli.install.description')
    option :destination, aliases: '-d', desc: I18n.t('sourcerer.cli.install.options.destination.description')
    option :force, aliases: '-f', default: false, desc: I18n.t('sourcerer.cli.install.options.force.description')
    option :type, aliases: '-t', default: :any, desc: I18n.t('sourcerer.cli.install.options.type.description')
    option :version, aliases: '-v', default: :latest, desc: I18n.t('sourcerer.cli.install.options.version.description')
    def install name
      # search for package
      packages = Sourcerer::Package.search name: name, version: options[:version], type: options[:type].to_sym

      # if a single package is found, continue
      if packages[:success].length == 1
        package = packages[:success].first

      # if multiple packages are found, prompt user to choose a package type
      elsif packages[:success].length > 1
        packages_hash = Hash[packages[:success].collect{ |package| [package.type.to_s, package] }]
        selected_package = CliMiami::A.sk I18n.t('sourcerer.cli.install.multiple_packages_found', name: name.green), type: :multiple_choice, choices: packages_hash, max: 1
        package = selected_package.values.first

      # if no packages are found, show errors and exit
      elsif packages[:success].length == 0
        CliMiami::S.ay I18n.t('sourcerer.errors.cli.install.no_package_found', name: name), preset: :sourcerer_success

        # show errors from each attempted package type search
        packages[:fail].each do |package|
          package.errors.each do |error|
            CliMiami::S.ay error.message, preset: :sourcerer_error
          end
        end
      end

      return unless package

      # install package
      CliMiami::S.ay I18n.t('sourcerer.cli.install.pending', name: name, version: package.version, type: package.type.to_s), preset: :sourcerer_pending
      package.install destination: options[:destination], force: options[:force]

      CliMiami::S.ay I18n.t('sourcerer.cli.install.success'), preset: :sourcerer_success
    end

    desc 'help [COMMAND]', I18n.t('sourcerer.cli.help.description')
    def help command = nil
      super
    end
  end
end
