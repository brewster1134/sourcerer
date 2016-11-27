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
