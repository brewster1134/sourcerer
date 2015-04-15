# coding: utf-8
Gem::Specification.new do |s|
  s.homepage = 'https://github.com/brewster1134/sourcerer'
  s.name = 'sourcerer_'
  s.version = '1.0.0'
  s.date = '2015-04-14'
  s.summary = 'Consume remote sources with ease.'
  s.files = ["lib/sourcerer/source_type.rb", "lib/sourcerer/source_types/dir.rb", "lib/sourcerer/source_types/git.rb", "lib/sourcerer/source_types/zip.rb", "lib/sourcerer.rb"]
  s.authors = ["Ryan Brewster"]
  s.add_runtime_dependency 'activesupport', '~> 4.1'
  s.add_runtime_dependency 'archive-zip', '~> 0.7'
  s.add_runtime_dependency 'git', '~> 1.2'
  s.add_development_dependency 'coveralls', '~> 0.7'
  s.add_development_dependency 'guard', '~> 2.6'
  s.add_development_dependency 'guard-bundler', '~> 2.1'
  s.add_development_dependency 'guard-rspec', '~> 4.3'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'terminal-notifier-guard', '~> 1.5'
end
