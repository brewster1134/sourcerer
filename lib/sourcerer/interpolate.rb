require 'erb'
require 'recursive-open-struct'
require 'tmpdir'

module Sourcerer::Interpolate
  # regex to match capital underscored template options names ie [PROJECT_NAME]
  FILENAME_RENAME_MATCH = /\[([A-Z_.]+)\]/

  # Convienance method for processing everything
  #
  def interpolate
    # puts 'pre paths', Dir.glob(File.join(@destination, '**/*')).inspect
    process_paths
    # puts 'pre files', Dir.glob(File.join(@destination, '**/*')).inspect
    process_files
  end

private

  # Convert options to OpenStruct so we can use dot notation in the templates
  #
  def data
    @data ||= RecursiveOpenStruct.new(@interpolation_data)
  end

  # Allow templates to call option values directly
  #
  def method_missing method
    data.send(method.to_sym) || super
  end

  # Collect files with a matching value to interpolate
  #
  def process_paths
    get_path = -> type do
      Dir.glob(File.join(@destination, '**/*')).select do |e|
        File.send("#{type}?".to_sym, e) && e =~ FILENAME_RENAME_MATCH
      end
    end

    # rename directories first
    get_path[:directory].each{ |dir| process_path dir }
    get_path[:file].each{ |file| process_path file }
  end

  # Interpolate filenames with template options
  #
  def process_path path
    new_path = path.gsub FILENAME_RENAME_MATCH do
      # Extract interpolated values into symbols
      methods = $1.downcase.split('.').map(&:to_sym)

      # Call each method on options
      methods.inject(data){ |options, method| options.send(method.to_sym) }
    end

    FileUtils.mv path, new_path
  end

  # Collect files with an .erb extension to interpolate
  #
  def process_files
    Dir.glob(File.join(@destination, '**/*.sourcerer'), File::FNM_DOTMATCH).each do |file|
      process_file file
    end
  end

  # Interpolate erb template data
  #
  def process_file file
    # Process the erb file
    processed_file = ERB.new(File.read(file)).result(binding)

    # Overwrite the original file with the processed file
    File.open file, 'w' do |f|
      f.write processed_file
    end

    # Remove the .erb from the file name
    FileUtils.mv file, file.chomp('.sourcerer')
  end
end
