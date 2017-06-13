module Sourcerer
  module Version
    # Searchs for a matching version based on user criteria and available versions
    #
    # @param version [String, Semantic::Version] A user provided tag or semantic version partial to search for
    # @param versions_array [Array] An array of all the available tags or versions
    # @return [String]
    #
    def find_matching_version version:, versions_array:
      # if version isn't a semantic version, but has a semantic version wildcard/operator
      if !version.is_a?(Semantic::Version) && version.match(Sourcerer::SEMANTIC_VERSION_WILDCARD_REGEX)
        find_matching_semantic_version criteria: version, versions_array: versions_array
      elsif versions_array.include? version
        version.to_s
      else
        nil
      end
    end

    private

    # Given a partial, or version with an operator, filters the available versions by the criteria requirements
    #
    def find_matching_semantic_version criteria:, versions_array:
      operator = criteria.match(/^([^0-9]*)/)[1].strip
      has_placeholder = !criteria.scan(/\.x/).empty?

      # create filter variables
      filtered_versions = versions_array.dup
      filters = []

      # no operator
      # if operator == nil && minor != 'x' && patch != 'x' && pre_major != 'x' && pre_minor != 'x' && pre_patch != 'x'
      if operator.empty? && !has_placeholder
        filters << {
          operator: '==',
          criteria: get_valid_semantic_version(criteria: criteria)
        }

      # ~, ~> (pessimistic) operators, or .x placeholders
      # elsif operator == nil || operator == '~' || operator == '~>'
      elsif operator.include? '~' || has_placeholder
        # add >= filter critera
        filters << {
          operator: '>=',
          criteria: get_valid_semantic_version(criteria: criteria)
        }

        # add < filter critera
        filters << {
          operator: '<',
          criteria: get_valid_semantic_version(criteria: criteria, increment: true)
        }

      # >=, >, <=, < operators
      else
        filters << {
          operator: operator,
          criteria: get_valid_semantic_version(criteria: criteria)
        }
      end

      # apply all filters
      filters.each do |filter|
        filtered_versions = filter_versions versions_array: filtered_versions, operator: filter[:operator], version: filter[:criteria]
      end

      return filtered_versions.max
    end

    # Array Legend
    # 1         2      3      4      5    6          7          8          9
    # operator, major, minor, patch, pre, pre_major, pre_minor, pre_patch, build
    #
    def get_valid_semantic_version criteria:, increment: false
      # create copy of criteria area and replace .x placeholder
      criteria_array = criteria.match(Sourcerer::SEMANTIC_VERSION_ARTIFACT_REGEX).to_a
      criteria_array_copy = criteria_array.dup.map{ |x| x == 'x' ? '0' : x }

      # remove operator
      criteria_array_copy[1] = nil

      # set meta data variables
      operator = criteria_array[1]
      is_placeholder = criteria_array.include?('x')
      is_exact_version = criteria_array[1].nil? && !is_placeholder

      if increment
        # increment major & reset minor, patch
        if !criteria_array[3] || (criteria_array[3] && !criteria_array[4])
          criteria_array_copy[2] = criteria_array[2].to_i.+(1).to_s
          criteria_array_copy[3] = '0'
          criteria_array_copy[4] = '0'
        end

        # increment minor & reset patch
        if criteria_array[4] && !criteria_array[5]
          criteria_array_copy[3] = criteria_array[3].to_i.+(1).to_s
          criteria_array_copy[4] = '0'
        end

        # drop pre
        if (criteria_array[5] && !criteria_array[6]) || criteria_array[6] == 'x'
          criteria_array_copy[5] = nil
        end

        # increment pre_major & reset pre_minor, pre_patch
        if criteria_array[5] && criteria_array[6] && !criteria_array[8]
          criteria_array_copy[6] = criteria_array[6].to_i.+(1).to_s
          criteria_array_copy[7] = '0'
          criteria_array_copy[8] = '0'
        end

        # increment pre_minor & reset pre_patch
        if criteria_array[8] && !criteria_array[9]
          criteria_array_copy[7] = criteria_array[7].to_i.+(1).to_s
          criteria_array_copy[8] = '0'
        end

        # remove build
        if criteria_array[9]
          criteria_array_copy[9] = nil
        end

      # do not increment anything
      else
        # reset minor
        if !criteria_array[3]
          criteria_array_copy[3] = '0'
        end

        # reset patch
        if !criteria_array[4]
          criteria_array_copy[4] = '0'
        end

        # reset pre_major, pre_minor, pre_patch
        if criteria_array[5] && !criteria_array[6]
          criteria_array_copy[6] = '0'
          criteria_array_copy[7] = '0'
          criteria_array_copy[8] = '0'
        end

        # pre_minor, pre_patch
        if criteria_array[6] && !criteria_array[7]
          criteria_array_copy[7] = '0'
          criteria_array_copy[8] = '0'
        end

        # pre_patch
        if criteria_array[7] && !criteria_array[8]
          criteria_array_copy[8] = '0'
        end
      end

      assemble_semantic_version criteria_array: criteria_array_copy
    end

    # create a valid semantic version string from a sourcerer criteria array
    # @param [Array]  A sourcerer criteria array
    # @return [String]  A valud semantic version string
    #
    def assemble_semantic_version criteria_array:
      criteria_string = ''
      criteria_string << criteria_array[2]
      criteria_string << '.'
      criteria_string << (criteria_array[3] || '0')
      criteria_string << '.'
      criteria_string << (criteria_array[4] || '0')
      if criteria_array[5]
        criteria_string << '-'
        criteria_string << criteria_array[5]
        criteria_string << '.'
        criteria_string << (criteria_array[6] || '0')
        criteria_string << '.'
        criteria_string << (criteria_array[7] || '0')
        criteria_string << '.'
        criteria_string << (criteria_array[8] || '0')
        if criteria_array[9]
          criteria_string << criteria_array[9]
        end
      end

      return criteria_string
    end

    def filter_versions versions_array:, operator:, version:
      versions_array.select do |v|
        v.send operator.to_sym, version
      end

      # # find all semantic versions
      # semantic_versions = versions_array.select{ |version| Semantic::Version.new(version) rescue false }
    end
  end
end
