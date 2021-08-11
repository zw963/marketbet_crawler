Rake.add_rakelib 'lib/tasks'

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs = ['lib', 'test']
  t.ruby_opts = ['-rminitest/autorun', '-rminitest/pride']
  t.test_files = FileList['test/**/**_test.rb']
end

Rake::TestTask.new do |t|
  t.name = 'spec'
  t.description = 'Run specs'
  t.libs = ['lib', 'spec']
  t.ruby_opts = ['-rminitest/autorun', '-rminitest/pride', '-rminitest/global_expectations/autorun']
  t.test_files = FileList['spec/**/**_spec.rb']
end

task default: :test
