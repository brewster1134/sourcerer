require 'thor'

class Sourcerer
  class Cli < Thor
    default_task :install

    desc 'install [PACKAGE NAME]', I18n.t('sourcerer.cli.install.description')
    option :destination, aliases: '-d', default: Sourcerer::DEFAULT_DESTINATION , desc: I18n.t('sourcerer.cli.install.options.destination_description')
    option :force, aliases: '-f', type: :boolean, default: Sourcerer::DEFAULT_FORCE , desc: I18n.t('sourcerer.cli.install.options.force_description')
    option :type, aliases: '-t', default: Sourcerer::DEFAULT_TYPE , desc: I18n.t('sourcerer.cli.install.options.type_description')
    option :version, aliases: '-v', default: Sourcerer::DEFAULT_VERSION , desc: I18n.t('sourcerer.cli.install.options.version_description')
    def install name
      Sourcerer.install name, cli: true, destination: options[:destination], force: options[:force], type: options[:type], version: options[:version]
    end

    desc 'help [COMMAND]', I18n.t('sourcerer.cli.help.description')
    def help command = nil
      super
    end
  end

  def prompt_for_package packages
    packages_hash = Hash[packages.collect{ |package| [package.type.to_s, package] }]
    selected_package = CliMiami::A.sk I18n.t('sourcerer.cli.prompt_for_package', name: name.green), type: :multiple_choice, choices: packages_hash, max: 1
    selected_package.values.first
  end
end
