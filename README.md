[![gem version](https://badge.fury.io/rb/sourcerer.svg)](https://badge.fury.io/rb/sourcerer)
[![dependencies](https://gemnasium.com/brewster1134/sourcerer.svg)](https://gemnasium.com/brewster1134/sourcerer)
[![docs](http://inch-ci.org/github/brewster1134/sourcerer.svg?branch=master)](http://inch-ci.org/github/brewster1134/sourcerer)
[![build](https://travis-ci.org/brewster1134/sourcerer.svg?branch=master)](https://travis-ci.org/brewster1134/sourcerer)
[![coverage](https://coveralls.io/repos/brewster1134/sourcerer/badge.svg?branch=master)](https://coveralls.io/r/brewster1134/sourcerer?branch=master)
[![code climate](https://codeclimate.com/github/brewster1134/sourcerer/badges/gpa.svg)](https://codeclimate.com/github/brewster1134/sourcerer)

# Sourcerer
A package manager
---
### Feature Roadmap
* Support a global Configuration `~/.sourcerer_config.yml`
* Support caching remote sources `~/.sourcerer_cache.yml`
* Support a project manifest `./sourcerer.yml`
* Type:
  * bower https://github.com/bower/registry
    * `jquery`
  * gem
    * `rails`
  * git
    * github
      * `https://github.com/brewster1134/sourcerer.git`
      * `https://github.com/brewster1134/sourcerer`
      * `git@github.com:brewster1134/sourcerer.git`
      * `git@github.com:brewster1134/sourcerer`
      * `git+https://github.com/brewster1134/sourcerer.git`
      * `git+https://github.com/brewster1134/sourcerer`
      * `git+ssh://git@github.com/brewster1134/sourcerer.git`
      * `git+ssh://git@github.com/brewster1134/sourcerer`
      * `brewster1134/sourcerer`
    * bitbucket
      * `https://brewster1134@bitbucket.org/brewster1134/sourcerer.git`
      * `https://brewster1134@bitbucket.org/brewster1134/sourcerer`
      * `git@bitbucket.org:brewster1134/sourcerer.git`
      * `git@bitbucket.org:brewster1134/sourcerer`
      * `git+https://git@bitbucket.org:brewster1134/sourcerer.git`
      * `git+https://git@bitbucket.org:brewster1134/sourcerer`
      * `git+ssh://git@bitbucket.org:brewster1134/sourcerer.git`
      * `git+ssh://git@bitbucket.org:brewster1134/sourcerer`
      * `brewster1134/sourcerer`
    * repo
      * `https://website.com/brewster1134/sourcerer.git`
  * local
    * `relative/path`
    * `/absolute/path`
  * npm
    * `grunt`
  * url
    * single asset
      * `https://raw.githubusercontent.com/brewster1134/sourcerer/master/README.md`
    * archive (will be extracted)
      * `https://github.com/brewster1134/sourcerer/archive/master.zip`
      * `https://github.com/brewster1134/sourcerer/archive/master.tar.gz`
* Version:
  * bower
    * [latest](https://github.com/bower/registry/issues/26)
      * `http://bower.herokuapp.com/packages/jquery`
  * gem http://guides.rubygems.org/rubygems-org-api/
    * latest
      * `https://rubygems.org/api/v1/versions/rails/latest.json`
      * `https://rubygems.org/api/v1/versions/rails/latest.yaml`
    * version, sha
      * `https://rubygems.org/api/v1/versions/rails.json`
      * `https://rubygems.org/api/v1/versions/rails.yaml`
  * git
    * github https://developer.github.com/v3/repos/
      * latest
        * `https://api.github.com/repos/brewster1134/sourcerer/releases/latest`
      * version
        * `https://api.github.com/repos/brewster1134/sourcerer/releases`
      * tag
        * `https://api.github.com/repos/brewster1134/sourcerer/releases/tags/stable`
      * branch
        * `https://api.github.com/repos/brewster1134/sourcerer/branches`
      * commit
        * `https://api.github.com/repos/brewster1134/sourcerer/commits`
    * bitbucket
      * latest
        * TODO
      * version
        * TODO
      * tag
        * TODO
      * branch
        * TODO
      * commit
        * TODO
    * repo
      * latest
        * `git clone origin master`
      * version
        * `git tag`
      * tag
        * `git tag`
      * branch
        * `git branch`
      * commit
        * `git log --pretty=oneline`
  * local
    * latest
    * git _see git:repo type_
  * npm
    * latest
      * `http://registry.npmjs.org/grunt/latest`
    * version, tags
      * `http://registry.npmjs.org/grunt`
  * url
    * latest

## Development
#### Creating a Package Type

```ruby
module Sourcerer
  module Packages                           # 1
    class Foo < Sourcerer::Package          # 2
      # @see Sourcerer::Package#search
      #
      def search package_name:, version:    # 3
        # INSERT SEARCH LOGIC HERE          # 3.1
        return 'source'                     # 3.2

        add_error 'foo.search.problem_x'    # 5
        return false                        # 3.3
      end

      # @see Sourcerer::Package#download
      #
      def download source:                  # 4
        # INSERT DOWNLOAD LOGIC HERE        # 4.1
        return '/path/to/tmp/dir'           # 4.2

        add_error 'foo.download.problem_y'  # 5
        return false                        # 4.3
      end
    end
  end
end
```

1. Namespace with `Sourcerer::Packages`
2. Inherit from `< Sourcerer::Package`
3. Define a `search` method that accepts `package_name` & `version`
  1. Write code to search for a compatible version based on the package `name` & `version`
  2. If a compatible package is found, return the `source` that the `download` method requires
  3. If no package could be found, `return false`
4. Define a `download` method that accepts `source`
  1. Write code to download the package from the `source` to a tmp directory
  2. If download completes return the path to the tmp directory
  3. If download fails, `return false`
5. If an error occurs, call the `add_error` method
  * _see below_

```yaml
en: &en
  sourcerer:
    errors:
      packages:                                   # 1
        foo:
          search:
            problem_x: Describe problem X         # 2
          download:
            problem_y: Describe problem Y %{foo}  # 3
```

```ruby
add_error 'foo.search.problem_x'                  # 2
add_error 'foo.download.problem_y', foo: 'bar'    # 3
```

1. Add i18n values for your errors, namespaced with `en.sourcerer.errors.packages`
2. Further namespace your error with the name of the type & the method `foo.search`
3. Optionally you can pass values into your error using the format `%{foo}`
