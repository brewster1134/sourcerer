class Sourcerer
  module Packages
    class Git < Sourcerer::Package
      GIT_REGEX = /(.+?)?([^\/:]+)\/([^\/]+?)(?:.git)?$/

      # @see Sourcerer::Package#search
      #
      def search
        a, domain, @user, @repo = name.match(GIT_REGEX).to_a

        @remote_source = does_remote_repo_exists @user, @repo

        !!@remote_source
      end

      # @see Sourcerer::Package#versions
      #
      def versions
        case @remote_source
        when :github
          releases_json = JSON.load(RestClient.get("https://api.github.com/repos/#{@user}/#{@repo}/releases")).map{ |v| v['tag_name'] }
          tags_json = JSON.load(RestClient.get("https://api.github.com/repos/#{@user}/#{@repo}/tags")).map{ |v| v['name'] }
          (releases_json + tags_json).uniq
        when :bitbucket
        else
          nil
        end
      end

      # @see Sourcerer::Package#download
      #
      def download to:
        case @remote_source
        when :github

        when :bitbucket
        else
          nil
        end
      end

      private

      def does_remote_repo_exists user, repo
        return :github if RestClient.get("https://github.com/#{user}/#{repo}") rescue false
        return :bitbucket if RestClient.get("https://bitbucket.org/#{user}/#{repo}") rescue false
        return nil
      end

      def get_github_releases
      end
    end
  end
end
