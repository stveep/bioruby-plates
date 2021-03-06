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
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "bio-plates"
  gem.homepage = "http://github.com/stveep/bioruby-plates"
  gem.license = "MIT"
  gem.summary = %Q{Methods for handling multiwell plate annotations}
  gem.description = %Q{Methods for handling multiwell plate annotations, includes ranges and quadrants}
  gem.email = "spettitt@gmail.com"
  gem.authors = ["Steve Pettitt"]
  gem.version = "0.2.2"
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) } 
  gem.required_ruby_version = '>= 2.1.0'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bio-plates #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
