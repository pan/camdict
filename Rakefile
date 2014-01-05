require 'rake/testtask'

Rake::TestTask.new(:default) do |t|
  t.test_files = FileList['test/test_*.rb']
end

Rake::TestTask.new(:itest) do |t|
  t.test_files = FileList['test/itest_*.rb']
end

desc "No internet connection required"
task :default => :test

desc "Needs internet connection"
task :itest => :test

desc "Run all tests"
task :testall => :default
task :testall => :itest
  
