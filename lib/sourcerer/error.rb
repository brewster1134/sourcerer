#
# Sourcerer::Error
# Custom error class
#
class Sourcerer::Error < StandardError
  # @param i18n_keys      [String]  Dot delimited heirarchy of i18n key
  # @param i18n_args_hash [Hash]    Object of values to pass to i18n
  # @return [Sourcerer::Error]
  #
  def initialize i18n_keys, i18n_args_hash = {}
    error = I18n.t "sourcerer.error.#{i18n_keys}", i18n_args_hash
    super error
  end
end
