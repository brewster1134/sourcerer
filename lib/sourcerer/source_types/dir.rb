class Sourcerer::SourceType::Dir < Sourcerer::SourceType
  def move
    FileUtils.cp_r "#{@source}/.", @destination
  end
end
