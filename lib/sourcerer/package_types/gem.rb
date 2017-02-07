module Sourcerer
  module Packages
    class Gem < Sourcerer::Package
      # @see Sourcerer::Package#search
      #
      def search package_name:, version:
      end

      # @see Sourcerer::Package#download
      #
      def download
      end

      # @see Sourcerer::Package#versions
      #
      def versions package_name:
      end

      private

      def get_latest_version package_name:
        response = RestClient.get "https://rubygems.org/api/v1/versions/#{package_name}/latest.yaml"
        YAML.load(response)['version']
      rescue
        nil
      end

      def get_url_by_version package_name:, version:
        response = RestClient.get "https://rubygems.org/api/v1/versions/#{package_name}.yaml"
        versions = YAML.load(response)

        versions.find{ |v| v['number'] == version.to_s } || nil
      rescue
        nil
      end
    end
  end
end
