notification :terminal_notifier, subtitle: 'Sourcerer'

guard :bundler do
  watch 'Gemfile'
  watch %r{.*\.gemspec}
end

guard :rubocop, all_on_start: false, keep_failed: false do
  watch(%r{(.+\.rb)$})        { |m| m[0] }
  watch(%r{\.rubocop\.yml$})  { '.' }
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/lib/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})         { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')      { 'spec' }
end
