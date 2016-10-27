#
# Sourcerer::SourceType
# Base class for supported source types
#
class Sourcerer::SourceType
  def initialize source, destination, options
    @destination = destination

    # calls the custom `move` method for the given type
    move source, destination, options
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

    files = ::Dir.glob(File.join(@destination, glob), File::FNM_DOTMATCH).select do |file|
      File.file? file
    end

    if relative
      base_path = Pathname.new @destination
      files = files.collect do |file|
        Pathname.new(file).relative_path_from(base_path).to_s
      end
    end

    files
  end
end
