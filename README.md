[![gem version](https://badge.fury.io/rb/sourcerer_.svg)](https://rubygems.org/gems/sourcerer_)
[![dependencies](https://gemnasium.com/brewster1134/sourcerer.svg)](https://gemnasium.com/brewster1134/sourcerer)
[![docs](http://inch-ci.org/github/brewster1134/sourcerer.svg?branch=master)](http://inch-ci.org/github/brewster1134/sourcerer)
[![build](https://travis-ci.org/brewster1134/sourcerer.svg?branch=master)](https://travis-ci.org/brewster1134/sourcerer)
[![coverage](https://coveralls.io/repos/brewster1134/sourcerer/badge.svg?branch=master)](https://coveralls.io/r/brewster1134/sourcerer?branch=master)
[![code climate](https://codeclimate.com/github/brewster1134/sourcerer/badges/gpa.svg)](https://codeclimate.com/github/brewster1134/sourcerer)

# SOURCERER
###### Consume local & remote sources with ease
---

From inside a ruby app, you can quickly grab entire directories of assets, either locally from a zip file or folder, or remotely from a git repo or zip file.

---
#### Install
```shell
gem install sourcerer_
```

---
#### Quick Usage
```ruby
require 'sourcerer'

# download a remote github repo to your Documents folder
source = Sourcerer.new 'brewster1134/sourcerer', '~/Documents/sourcerer'

# use file globbing to return a custom array of files
source.files '**/*_helper.rb'
=> ["spec/spec_helper.rb"]
```

---
#### Supported Sources
* git repo
  * local or remote
  * github shorthand _(see example)_
* zip files
  * local or remote
* local directories _(although not very useful)_
  * relative or absolute paths

---
#### Roadmap
* Command line tool
* Automate consuming multiple sources with a sourcerer.yaml file
* Support for branches, tags & commits from a git repo

---
#### Development
###### Install Dependencies
```shell
# clone repo
git clone https://github.com/brewster1134/sourcerer.git
cd sourcerer

# install dependencies
bundle install

# run watcher for linting and tests
bundle exec guard
```

[![WTFPL](http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-4.png)](http://www.wtfpl.net)
