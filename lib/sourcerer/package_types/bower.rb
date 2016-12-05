module Sourcerer
  module Packages
    class Bower < Sourcerer::Package
      def search package_name:, version:
        url = url package_name

        # if no package url was found, return nil
        return nil if url.nil?

        # if package url was found, search for a package with a matching version
        packages = Sourcerer::Package.search package_name: package_name, version: version, type: [:git, :url]

        # if package was found...
        if packages.length == 1
          return packages.first

        # if multiple packages were found (this should never happen)...
        elsif packages.length > 1
          return nil

        # if package was not found...
        elsif packages.length == 0
          return nil
        end
      end

      def download
      end

      private

      # Get Bower package url
      #
      def url package_name
        begin
          package_response = RestClient.get "http://bower.herokuapp.com/packages/#{package_name}"
          return package_response['url']
        rescue
          add_error 'packages.no_package_found', package_name: package_name, package_type: type
          return nil
        end
      end

      # def installed?
      #   system 'bower'
      #   $?.exitstatus == 0
      # end
    end
  end
end
