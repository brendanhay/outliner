# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "outliner"
  gem.homepage = "http://github.com/brendanhay/outliner"
  gem.license = "MIT"
  gem.summary = 'Ruby implementation of the HTML5 outline algorithm'
  gem.description = 'A preliminary attempt at using the HTML5 outline algorithm from: http://dev.w3.org/html5/spec/sections.html#outline - to generate table of contents and automatic numbering for markdown documents.'
  gem.email = "brendan.g.hay@gmail.com"
  gem.authors = ["brendanhay"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "outliner #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# PRIVATE GEM: Remove tasks for releasing this gem to Gemcutter
tasks = Rake.application.instance_variable_get('@tasks')
tasks.delete('release')
tasks.delete('gemcutter:release')
tasks.delete('console')

desc 'Start a console with all necessary files required.'
task :console do |t|
  chdir File.dirname(__FILE__)
  exec 'irb -I lib/ -I lib/outliner -r rubygems -r outliner'
end
