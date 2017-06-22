module Sourcerer
  module Packages
    class Bower < Sourcerer::Package
      # @see Sourcerer::Package#search
      #
      def search
        # check to see if package exists
        url = get_url name
        return false if url.nil?

        # search for package with the url, and return false unless a single package isn't found
        url_packages = Sourcerer::Package.search name: name, version: version, type: :git
        return false unless url_packages[:success].length == 1

        # package found. set the new package and return source
        @url_package = url_packages[:success].first

        return !!@url_package.version
      end

      # @see Sourcerer::Package#download
      #
      def download to:
        @url_package.download to: to
      end

      # @see Sourcerer::Package#versions
      #
      def versions
        @url_package.versions
      end

      private

      # Get Bower package url
      #
      def get_url name
        response = RestClient.get "http://bower.herokuapp.com/packages/#{name}"
        JSON.load(response)['url']
      rescue
        nil
      end
    end
  end
end
