#
# Sourcerer::SourceType
# Base class for supported source types
#
class Sourcerer::SourceType
  attr_reader :path
  
  def initialize source, destination, options
    @path = destination

    # raise error if destination already exists
    if ::Dir.exist? @path
      raise Sourcerer::Error.new 'source_type.initialize.destination_already_exists', destination: @path
    end

    # calls the custom `move` method for the given type
    move source, destination, options

    self
  end

  # Return an array of file paths that match the provided glob
  #
  def files glob = :all, relative = false
    glob = case glob
    when :all
      '**/*'
    when :hidden
      '**/.*'
    else
      glob
    end

    files = ::Dir.glob(File.join(@path, glob), File::FNM_DOTMATCH).select do |file|
      File.file? file
    end

    if relative
      base_path = Pathname.new @path
      files = files.collect do |file|
        Pathname.new(file).relative_path_from(base_path).to_s
      end
    end

    files
  end
end
