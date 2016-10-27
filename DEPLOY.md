#### Deployment Steps
* bump version in `metadata.rb`
* add entry in `CHANGELOG.md`
* run `bundle update`
* commit changes `git add -A; git commit -m "0.0.0.pre"`
* add tag `git tag -a 0.0.0.pre`
* add version to tag message `0.0.0.pre`
* push commit and tags `git push --follow-tags`
* check travis logs `https://travis-ci.org/brewster1134/sourcerer` for successful build & deploy
* check github `https://github.com/brewster1134/sourcerer/releases` for new release with downloadable gem asset
* check rubygems `https://rubygems.org/gems/sourcerer_` for new version
