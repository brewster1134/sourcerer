# Sourcerer
A package manager
---
### Feature Roadmap
* Support a manifest `sourcerer.yml`
* Sources:
  * gem registry 
    * rake
  * npm registry
    * gulp
  * bower registry https://github.com/bower/registry
    * jquery
  * git repo
    * git endpoint
      * https://github.com/user/repo.git
      * git@github.com:user/repo.git
      * git+https://github.com/user/repo
      * git+ssh://git@github.com/user/repo
    * github shorthand
      * user/repo
    * git tags
      * https://github.com/user/repo.git#[TAG]
      * https://github.com/user/repo.git#[COMMIT_SHA]
      * https://github.com/user/repo.git#[BRANCH]
  * url
    * http://example.com/asset.rb
  * archives (will be extracted)
    * http://example.com/asset.tar
    * http://example.com/asset.gz
    * http://example.com/asset.zip
  * local directory
    * relative/path
    * /absolute/path
* Criteria:
  * latest
    * `latest`
    * `*`
  * semver https://github.com/rubygems/rubygems/blob/master/lib/rubygems/version.rb
    * `1.2.3`
    * `1.2.x`
    * `1.x`
  * git
    * branch
    * tag
    * commit sha
  