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

  s.required_ruby_version = Gem::Requirement.new '>= 2.1.0'
  
  s.add_runtime_dependency 'activesupport', '~> 0'
  s.add_runtime_dependency 'i18n', '~> 0'
  s.add_runtime_dependency 'thor', '~> 0'
end