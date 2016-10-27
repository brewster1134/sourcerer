[![gem version](https://badge.fury.io/rb/sourcerer_.svg)](https://rubygems.org/gems/sourcerer_)
[![dependencies](https://gemnasium.com/brewster1134/sourcerer.svg)](https://gemnasium.com/brewster1134/sourcerer)
[![docs](http://inch-ci.org/github/brewster1134/sourcerer.svg?branch=master)](http://inch-ci.org/github/brewster1134/sourcerer)
[![build](https://travis-ci.org/brewster1134/sourcerer.svg?branch=master)](https://travis-ci.org/brewster1134/sourcerer)
[![coverage](https://coveralls.io/repos/brewster1134/sourcerer/badge.svg?branch=master)](https://coveralls.io/r/brewster1134/sourcerer?branch=master)
[![code climate](https://codeclimate.com/github/brewster1134/sourcerer/badges/gpa.svg)](https://codeclimate.com/github/brewster1134/sourcerer)

[![omniref](https://www.omniref.com/github/brewster1134/sourcerer.png)](https://www.omniref.com/github/brewster1134/sourcerer)

# SOURCERER
Consume remote sources with ease.

---
#### Install
```shell
gem install sourcerer_
```

---
#### Quick Usage
```ruby
require 'sourcerer'
source = Sourcerer.new 'brewster1134/sourcerer', destination: '~/Documents'
source.files '**/spec_helper.rb'
=> ["spec/spec_helper.rb"]
```

---
#### Supported Sources
* git repo
  * local or remote
  * github shorthand _(see example)_
* zip files
  * local or remote
* local directories _(not very helpful)_
  * relative or absolute paths

---
#### Development
###### Install Dependencies
```shell
gem install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/sourcerer/master/Yuyifile
bundle install
```

###### Tests
```shell
bundle exec guard
```

[![WTFPL](http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-4.png)](http://www.wtfpl.net)
