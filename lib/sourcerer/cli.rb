require 'thor'

module Sourcerer
  class Cli < Thor
    default_task :install
    
    desc 'install [PACKAGE]', I18n.t('sourcerer.cli.install.description')
    option :version, aliases: '-v', default: :latest, desc: I18n.t('sourcerer.cli.install.options.version.description')
    def install package
      Sourcerer.install package, options.symbolize_keys
    end
    
    desc 'help [COMMAND]', I18n.t('sourcerer.cli.help.description')
    def help command = nil
      super
    end    
  end
end