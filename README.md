[![Gem Version](https://badge.fury.io/rb/sourcerer_.svg)](http://badge.fury.io/rb/sourcerer_)
[![Build Status](https://travis-ci.org/brewster1134/sourcerer.svg?branch=master)](https://travis-ci.org/brewster1134/sourcerer)
[![Coverage Status](https://coveralls.io/repos/brewster1134/sourcerer/badge.png)](https://coveralls.io/r/brewster1134/sourcerer)

# sourcerer

#### Dependencies
* Ruby >= 1.9

#### Usage
Currently source types are:

* git repo
  * local or remote
  * github shorthand _(see example)_
* zip files
  * local or remote
* local directories _(not very helpful)_
  * relative or absolute paths

```ruby
require 'sourcerer'
source = Sourcerer.new 'brewster1134/sourcerer', '~/Downloads'
```

### Development

###### Install Dependencies
```sh
gem install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/sourcerer/master/yuyi_menu
```

##### Running Tests
```sh
bundle exec guard
```
