module Sourcerer
  module Version
    def find_matching_version version:, versions_array:
      # if version isn't a semantic version, but has a semantic version wildcard/pessimistic operator
      if !version.is_a?(Semantic::Version) && version.match(Sourcerer::SEMANTIC_VERSION_WILDCARD_REGEX)
        find_matching_semantic_version criteria: version, versions_array: versions_array
      else
        if versions_array.include? version
          version
        else
          nil
        end
      end
    end

    private

    def find_matching_semantic_version criteria:, versions_array:
      # extract version string into criteria artifacts
      criteria_array = criteria.match(Sourcerer::SEMANTIC_VERSION_ARTIFACT_REGEX).to_a

      #  1         2      3      4      5    6          7          8          9
      x, operator, major, minor, patch, pre, pre_major, pre_minor, pre_patch, build = criteria_array

      # create filter variables
      filtered_versions = versions_array.dup
      filters = []

      # no operator
      if operator == nil && minor != 'x' && patch != 'x' && pre_major != 'x' && pre_minor != 'x' && pre_patch != 'x'
        filters << {
          operator: '==',
          criteria: get_valid_semantic_version(criteria_array: criteria_array)
        }

      # pessimistic operator or .x placeholder
      elsif operator == nil || operator == '~' || operator == '~>'
        # add >= filter critera
        filters << {
          operator: '>=',
          criteria: get_valid_semantic_version(criteria_array: criteria_array)
        }

        # add < filter critera
        filters << {
          operator: '<',
          criteria: get_valid_semantic_version(criteria_array: criteria_array, increment: true)
        }

      # >=, >, <=, < operator
      else
        filters << {
          operator: operator,
          criteria: get_valid_semantic_version(criteria_array: criteria_array)
        }
      end

      # apply all filters
      filters.each do |filter|
        filtered_versions = filter_versions versions_array: filtered_versions, operator: filter[:operator], version: filter[:criteria]
      end

      return filtered_versions.max
    end

    def get_valid_semantic_version criteria_array:, increment: false
      operator = criteria_array[1]
      is_placeholder = criteria_array.include?('x')
      is_exact_version = criteria_array[1].nil? && !is_placeholder

      # create copy of criteria area and replace .x placeholder
      criteria_array_copy = criteria_array.dup.map{ |x| x == 'x' ? '0' : x }

      if increment
        # increment major version
        if !criteria_array[3]
          criteria_array_copy[2] = criteria_array[2].to_i.+(1).to_s
        end

        # increment major version & reset minor version
        if criteria_array[3] && !criteria_array[4]
          criteria_array_copy[2] = criteria_array[2].to_i.+(1).to_s
          criteria_array_copy[3] = '0'
        end

        # increment minor version & reset patch version
        if criteria_array[4] && !criteria_array[5]
          criteria_array_copy[3] = criteria_array[3].to_i.+(1).to_s
          criteria_array_copy[4] = '0'
        end

        # drop pre version
        if (criteria_array[5] && !criteria_array[6]) || criteria_array[6] == 'x'
          criteria_array_copy[5] = nil
        end

        # increment pre_major version
        if !criteria_array[7]
          criteria_array_copy[6] = criteria_array[6].to_i.+(1).to_s
        end

        # increment pre_major version & reset pre_minor version
        if criteria_array[7] && !criteria_array[8]
          criteria_array_copy[6] = criteria_array[6].to_i.+(1).to_s
          criteria_array_copy[7] = '0'
        end

        # increment pre_minor version & reset pre_patch version
        if (criteria_array[8] && (operator == '~' || operator == '~>') || criteria_array[8] == 'x')
          criteria_array_copy[7] = criteria_array[7].to_i.+(1).to_s
          criteria_array_copy[8] = '0'
        end

      # do not increment anything
      else
        # reset minor version
        if operator == '>=' && !criteria_array[3]
          criteria_array_copy[3] = '0'
        end

        # reset pre_major version
        if !is_exact_version && criteria_array[5] && !criteria_array[6]
          criteria_array_copy[6] = '0'
        end
      end

      assemble_semantic_version criteria_array: criteria_array_copy
    end

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
        if criteria_array[6]
          criteria_string << '.'
          criteria_string << criteria_array[6]
          criteria_string << '.'
          criteria_string << (criteria_array[7] || '0')
          criteria_string << '.'
          criteria_string << (criteria_array[8] || '0')
          if criteria_array[9]
            criteria_string << '-'
            criteria_string << criteria_array[9]
          end
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
