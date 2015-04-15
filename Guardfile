notification :terminal_notifier, subtitle: 'Sourcerer'

guard :bundler do
  watch('Gemfile')
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/lib/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
  watch(%r{lib/sourcerer/source_types/.+\.rb$}) { 'spec/lib/sourcerer/source_type_spec.rb' }
end
