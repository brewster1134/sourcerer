# 
# Sourcerer Namespace
# lib/sourcerer.rb
# 
require 'active_support/core_ext/hash/keys'
require 'i18n'

# I18N
I18n.load_path += Dir[File.join('i18n', '*.yml')]
I18n.locale = ENV['LANG'].split('.').first.downcase
I18n.reload!

module Sourcerer
  require 'sourcerer/meta'
  
  def self.install package, version: :latest
    puts package.inspect, version.inspect
    # Sourcerer::Source
  end
end
