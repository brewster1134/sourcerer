class Sourcerer::Error < StandardError
  def initialize i18n_keys, arg_hash = {}
    msg = I18n.t("sourcerer.errors.#{i18n_keys}", arg_hash)
    super msg
  end
end