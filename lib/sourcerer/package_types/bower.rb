module Sourcerer
  module Packages
    class Bower < Sourcerer::Package
      # @see Sourcerer::Package#search
      #
      def search package_name:, version:
        # look for package url, and return false if not found
        url = get_url package_name
        return false if url.nil?

        # search for package with the url, and return false unless a single package isn't found
        url_packages = Sourcerer::Package.search package_name: package_name, version: version, type: [:git, :url]
        return false unless url_packages.length == 1

        # package found. set the new package and return true
        @url_package = url_packages.first
        return true
      end

      # @see Sourcerer::Package#download
      #
      def download
        @url_package.download
      end

      private

      # Get Bower package url
      #
      def get_url package_name
        package_response = RestClient.get "http://bower.herokuapp.com/packages/#{package_name}"
        package_response['url']
      rescue
        nil
      end
    end
  end
end
