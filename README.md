![Travis CI](https://travis-ci.org/brewster1134/sourcerer.svg?branch=master)

# sourcerer

#### Dependencies
* Ruby >= 1.9

#### Usage
Currently source types are:

* directories
  * local relative or absolute paths
* git repo
  * local or remote
  * github shorthand _(see example)_
* zip files
  * local or remote

```ruby
require 'sourcerer'
source = Sourcerer.new 'brewster1134/sourcerer', '~/Downloads'
```

### Development

###### Install Dependencies
```sh
bundle install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/sourcerer/master/yuyi_menu
```

##### Running Tests
```sh
bundle exec guard
```
