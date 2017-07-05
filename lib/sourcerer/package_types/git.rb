class Sourcerer
  module Packages
    class Git < Sourcerer::Package
      GIT_REGEX = /([^\/:]+)\/([^\/]+?)(?:.git)?$/

      # @see Sourcerer::Package#search
      #
      def search
        d, @user, @repo = name.match(GIT_REGEX).to_a

        @remote_source = does_remote_repo_exist @user, @repo

        !!@remote_source
      end

      # @see Sourcerer::Package#versions
      #
      def versions
        case @remote_source
        when :github
          begin
            @releases_json = JSON.load(RestClient.get("https://api.github.com/repos/#{@user}/#{@repo}/releases"))
            @releases_versions = @releases_json.map{ |v| v['tag_name'] }
            @tags_json = JSON.load(RestClient.get("https://api.github.com/repos/#{@user}/#{@repo}/tags"))
            @tags_versions = @tags_json.map{ |v| v['name'] }

            (@releases_versions + @tags_versions).uniq
          rescue
            add_error 'versions.github'
            nil
          end
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
          tar_url = if @releases_versions.include? version
            @releases_json.first{ |v| v['tag_name'] }['tarball_url']
          elsif @tags_versions.include? version
            @tags_json.first{ |v| v['name'] }['tarball_url']
          end

          # download and extract
          response = RestClient.get(tar_url)
          tmp_file = Tempfile.new
          File.write(tmp_file.path, response.to_s)
          `tar -x -f #{tmp_file.path} -C #{to} --strip 1`
        when :bitbucket
        else
          nil
        end
      end

      private

      def does_remote_repo_exist user, repo
        return :github if RestClient.get("https://github.com/#{user}/#{repo}") rescue false
        return :bitbucket if RestClient.get("https://bitbucket.org/#{user}/#{repo}") rescue false
        return nil
      end

      def get_github_releases
      end
    end
  end
end
