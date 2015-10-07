#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'OpenSesame'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require "bundler/gem_tasks"

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  # t.pattern = "./spec/**/*_spec.rb" # default
  # Put spec opts in a file named .rspec in root
end

desc "Run the specs"
task :default => ["spec"]
