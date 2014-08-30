require 'open-uri'

class Sourcerer
  attr_reader :dest_dir, :source, :tmp_dir

  def initialize source, dest = nil
    @source = source
    @tmp_dir = Dir.mktmpdir
    @dest_dir = dest || @tmp_dir
  end

  def files glob = '**/*'
  end

private

    def detect_type source = @source
    end

    def copy_to_tmp
      if Dir.exists?(@source)
        FileUtils.cp_r Dir["#{@source}/*"], @tmp_dir

      elsif File.exists?(@source)
        FileUtils.cp @source, @tmp_dir
      end
    end
end
