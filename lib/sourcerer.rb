require 'open-uri'

class Sourcerer
  attr_reader :dest_dir, :source, :tmp_dir, :type

  def initialize source, dest = nil
    @source = source
    @tmp_dir = Dir.mktmpdir
    @dest_dir = dest || @tmp_dir

    detect_type source
  end

  def files glob = '**/*'
  end

private

    def detect_type source
      @type = case source
      # local/remote git repo
      when /.git$/
        :git

      # github shorthand
      when /^[A-Za-z0-9-]+\/[A-Za-z0-9\-_.]+$/
        :git

      # local/remote zip file
      when /.zip$/
        :zip

      # local dir
      else
        :dir if Dir.exists?(source)
      end
    end

    def copy_to_tmp
      if Dir.exists?(@source)
        FileUtils.cp_r Dir["#{@source}/*"], @tmp_dir

      elsif File.exists?(@source)
        FileUtils.cp @source, @tmp_dir
      end
    end
end
