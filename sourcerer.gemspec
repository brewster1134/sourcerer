# coding: utf-8
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'date'
require 'sourcerer/meta'

Gem::Specification.new do |s|
  s.name      = 'sourcerer_'
  s.version   = Sourcerer::VERSION
  s.summary   = Sourcerer::SUMMARY
  s.homepage  = 'https://github.com/brewster1134/sourcerer'
  s.license   = 'MIT'
  s.author    = 'Ryan Brewster'
  s.email     = 'brewster1134+sourcerer@gmail.com'

  # https://en.wikipedia.org/wiki/Ruby_(programming_language)#Table_of_versions
  s.required_ruby_version = '>= 2.3'

  s.add_runtime_dependency 'activesupport', '>0'
  s.add_runtime_dependency 'cli_miami', '>0'
  s.add_runtime_dependency 'i18n', '>0'
  s.add_runtime_dependency 'json', '>0'
  s.add_runtime_dependency 'rest-client', '>0'
  s.add_runtime_dependency 'semantic', '>0'
  s.add_runtime_dependency 'thor', '>0'

  s.add_development_dependency 'coveralls', '>0'
  s.add_development_dependency 'guard', '>0'
  s.add_development_dependency 'guard-bundler', '>0'
  s.add_development_dependency 'guard-rubocop', '>0'
  s.add_development_dependency 'guard-rspec', '>0'
  s.add_development_dependency 'rspec', '>0'
  s.add_development_dependency 'terminal-notifier', '>0'
  s.add_development_dependency 'terminal-notifier-guard', '>0'
end
