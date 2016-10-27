#
# Sourcerer::Core
# Base class for initializing Sourcerer
#
class Sourcerer::Core
  GIT_GITHUB_SHORTHAND_REGEX = %r{^[A-Za-z0-9-]+\/[A-Za-z0-9\-_.]+$}
  attr_reader :source

  # Initialize a new sourcerer core object
  # @param source       [String]  A valid source location or supported shorthand
  # @param destination  [String]  A local path to copy the source to, nil
  # @return [Sourcerer::SourceType[TYPE]]
  #
  def initialize source, destination, options
    # get absolute path of destination
    destination = File.expand_path(destination)

    # initialize a source type object
    type_source = options[:type] || get_type_source(source)
    type = type_source[:type]
    source = type_source[:source]
    type_class = get_type_class type
    type_class.new source, destination, options
  end

  # Determine the type of source based on a string
  # @param  source  [String]  A string representing a local or remote source location
  # @return [Hash]  An object with a supported source :type and :source
  # @raise [Sourcerer::Error] Could not determine the source type based on the provided source
  # @todo Add additional source types
  #
  # rubocop:disable Metrics/CyclomaticComplexity
  def get_type_source source
    type_source = nil

    # LOCAL
    #
    # => local directory
    expanded_source = File.expand_path(source)
    if Dir.exist?(expanded_source)
      type_source = {
        type: :dir,
        source: expanded_source
      }

    # => local file
    elsif File.exist?(expanded_source)
      case File.extname(expanded_source)

      # => local zip file
      when '.zip'
        type_source = {
          type: :zip,
          source: expanded_source
        }
      end

    # REMOTE
    #
    # => remote file
    else
      case File.extname(source)

      # => remote zip file
      when '.zip'
        type_source = {
          type: :zip,
          source: source
        }

      # => remote git repo
      when '.git', ''
        type_source = {
          type: :git,
          source: source
        }
      end
    end

    return type_source unless type_source.nil?

    # raise an error if no source type was found
    raise Sourcerer::Error.new 'core.get_type_source.no_type_detected', source: source
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # Initialize a new source type from the provided symbol
  # @param  type  [Symbol]  A supported source type name
  # @return [Sourcerer::SourceType::[TYPE]]
  #
  def get_type_class type
    "Sourcerer::SourceType::#{type.to_s.classify}".constantize
  end
end
