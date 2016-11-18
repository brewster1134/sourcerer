notification :terminal_notifier, subtitle: 'Sourcerer'

guard :bundler do
  watch 'Gemfile'
end

guard :rubocop, all_on_start: false, cli: 'bundle exec rubocop -D' do
  watch(/(.+\.rb)$/)                  { |m| m[0] }
  watch(%r{(?:.+/)?\.rubocop\.yml$})  { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/lib/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})       { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')    { 'spec' }
end
