#
# Sourcerer::SourceTypeDir
# Handler for zip file sources
#
class Sourcerer::SourceType::Zip < Sourcerer::SourceType
  require 'zip'

  def move source, destination, _options
    ::Zip::File.open(source) do |zip_file|
      zip_file.each do |file|
        file_path = File.join destination, file.name
        zip_file.extract(file, file_path) unless File.exist? file_path
      end
    end
  end
end
