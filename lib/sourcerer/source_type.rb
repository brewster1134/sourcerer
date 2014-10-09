class Sourcerer::SourceType
  # Init a new source type and make accessible to the sourcerer class
  #
  def self.inherited klass
    Sourcerer.addType klass
  end

  # Sourcerer class accessors
  #
  def source; Sourcerer.source; end
  def destination; Sourcerer.destination; end

  def files glob = :all
    glob = case glob
    when :all
      '**/{.[^\.]*,*}'
    when :hidden
      '**/.*}'
    else
      glob
    end

    Dir.glob(File.join(destination, glob)).select{ |file| File.file? file }
  end
end
