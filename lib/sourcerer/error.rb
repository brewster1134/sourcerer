class Sourcerer::Error < StandardError
  @@cli = nil
  def self.cli= cli
    @@cli = cli
  end

  def initialize i18n_keys, arg_hash = {}
    msg = I18n.t("sourcerer.errors.#{i18n_keys}", arg_hash)
    super msg
  end

  def print
    if @@cli == true
      CliMiami::S.ay message, preset: :sourcerer_error
    else
      raise self
    end
  end
end
