require 'active_support/core_ext/string/inflections'
require 'i18n'
require 'tmpdir'

# I18n
I18n.load_path += Dir[File.expand_path(File.join('i18n', '*.yml'))]
I18n.locale = ENV['LANG'].split('.').first.downcase
I18n.reload!

#
# Sourcerer
# Entrypoint & controller
#
module Sourcerer
  def self.new source, destination, options = {}
    Sourcerer::Core.new source, destination, options
  end
end

# SOURCERER LIBRARY
require 'sourcerer/core'
require 'sourcerer/error'
require 'sourcerer/metadata'
require 'sourcerer/source_type'

# Requre all source types
Dir[File.join(Dir.pwd, 'lib', 'sourcerer', 'source_types', '*.rb')].each do |file|
  require file
end
