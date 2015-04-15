class Sourcerer::SourceType
  attr_reader :source, :destination

  # requre all source types
  Dir[File.join(File.dirname(__FILE__), 'source_types', '*.rb')].each { |file| require file }

  def initialize sourcerer
    @source = sourcerer.source
    @destination = sourcerer.destination
    @options = sourcerer.options

    # runs source type specific `move` method to get files from the source to the destination
    move

    # append subdirectory if it exists
    if @options[:subdirectory]
      @destination = File.join @destination, @options[:subdirectory]
    end
  end

  # Return an array of file paths that match the provided glob
  #
  def files glob = :all, relative = false
    glob = case glob
    when :all
      '**/{.[^\.]*,*}'
    when :hidden
      '**/.*}'
    else
      glob
    end

    files = ::Dir.glob(File.join(@destination, glob)).select do |file|
      File.file? file
    end

    if relative
      base_path = Pathname.new @destination
      files = files.collect do |file|
        Pathname.new(file).relative_path_from(base_path).to_s
      end
    end

    return files
  end
end
