require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "tests"
  t.test_files = FileList['tests/*test.rb']
  t.verbose = true
end

task :setup do
  $LOAD_PATH.unshift('lib', 'tests')
  require './tests/setup'
end

task :default => [:test]