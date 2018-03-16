class Sourcerer
  module Packages
    class Npm < Sourcerer::Package
      # @see Sourcerer::Package#search
      #
      def search
        begin
          @npm_json = JSON.load(RestClient.get("http://registry.npmjs.org/#{name}"))
          return true
        rescue StandardError => e
          raise Sourcerer::Error.new 'no package'
        end
      end

      # @see Sourcerer::Package#download
      #
      def download to:
        tar_url = @npm_json['versions'][version.to_s]['dist']['tarball']
        download_tar url: tar_url, to: to
      end

      # @see Sourcerer::Package#versions
      #
      def versions
        @npm_json['versions'].map{ |k, v| v['version'] }.sort.reverse
      end

      def latest
        @npm_json['dist-tags']['latest']
      end
    end
  end
end
