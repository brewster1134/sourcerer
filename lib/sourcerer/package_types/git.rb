module Sourcerer
  module Packages
    class Git < Sourcerer::Package
      GIT_REGEX = /(.+?)?([^\/:]+)\/([^\/]+?)(?:.git)?$/

      # @see Sourcerer::Package#search
      #
      def search
        domain, user, repo = @name.match(GIT_REGEX).to_a

        @remote_source = does_remote_repo_exists user, repo

        !!@remote_source
      end

      # @see Sourcerer::Package#versions
      #
      def versions
        case @remote_source
        when :github
          versions_json = JSON.load(RestClient.get("https://api.github.com/repos/brewster1134/sourcerer/releases"))
          versions_json.map{ |v| v['tag_name'] }
        when :bitbucket
        else
          nil
        end
      end

      # @see Sourcerer::Package#download
      #
      def download
      end

      private

      def does_remote_repo_exists user, repo
        return :github unless RestClient.get("https://github.com/#{user}/#{repo}") rescue false
        return :bitbucket unless RestClient.get("https://bitbucket.org/#{user}/#{repo}") rescue false
        return nil
      end
    end
  end
end
