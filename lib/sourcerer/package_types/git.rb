class Sourcerer
  module Packages
    class Git < Sourcerer::Package
      GIT_REGEX = /([^\/:]+)\/([^\/]+?)(?:.git)?$/

      # @see Sourcerer::Package#search
      #
      def search
        d, @user, @repo = name.match(GIT_REGEX).to_a

        @repo_source = get_repo_source @user, @repo

        !!@repo_source
      end

      # @see Sourcerer::Package#versions
      #
      def versions
        case @repo_source
        when :github
          begin
            @releases_json = JSON.load(@releases_response)
            @releases_array = @releases_json.map{ |v| v['name'] }
            @tags_json = JSON.load(RestClient.get("https://api.github.com/repos/#{@user}/#{@repo}/tags"))
            @tags_array = @tags_json.map{ |v| v['name'] }

            (@releases_array + @tags_array).uniq
          rescue => e
            add_error 'versions.github', message: JSON.load(e.response)['message']
          end
        when :bitbucket
          nil
        else
          nil
        end
      end

      # @see Sourcerer::Package#download
      #
      def download to:
        case @repo_source
        when :github
          tar_url = if @releases_array.include? version.to_s
            @releases_json.first{ |v| v['name'] == version.to_s }['tarball_url']
          elsif @tags_array.include? version.to_s
            @tags_json.first{ |v| v['name'] == version.to_s }['tarball_url']
          end

          download_tar url: tar_url, to: to
        when :bitbucket
        else
          nil
        end
      end

      def pre_install
        # set name to just the repo name
        @name = @repo
      end

      private

      def get_repo_source user, repo
        return :github if @releases_response = RestClient.get("https://api.github.com/repos/#{user}/#{repo}/releases")
        return :bitbucket if @releases_response = RestClient.get("https://bitbucket.org/#{user}/#{repo}")
        return nil
      end

      def get_github_releases
      end
    end
  end
end
