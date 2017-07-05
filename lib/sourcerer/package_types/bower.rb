class Sourcerer
  module Packages
    class Bower < Sourcerer::Package
      # @see Sourcerer::Package#search
      #
      def search
        # check to see if package exists
        git_url = get_git_url name: name
        return false if git_url.nil?

        # search for package with the url, and return false unless a single package isn't found
        @git_package = Sourcerer.new cli: cli, destination: destination, force: force, name: git_url, type: :git, version: version
        return false if @git_package.version.nil?

        @git_package.install

        return true
      end

      # @see Sourcerer::Package#download
      #
      def download to:
      end

      # @see Sourcerer::Package#versions
      #
      def versions
        @git_package.versions
      end

      private

      # Get Bower package url
      #
      def get_git_url name:
        response = RestClient.get "http://bower.herokuapp.com/packages/#{name}"
        JSON.load(response)['url']
      rescue
        nil
      end
    end
  end
end
