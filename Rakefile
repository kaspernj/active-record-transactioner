require "rubygems"
require "bundler"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems"
  exit e.status_code
end
require "rake"

require "jeweler"
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "active-record-transactioner"
  gem.homepage = "http://github.com/kaspernj/active-record-transactioner"
  gem.license = "MIT"
  gem.summary = "Queue up calls to specific models and execute them in transactions, after a certain number of models have been added."
  gem.description = "Queue up calls to specific models and execute them in transactions, after a certain number of models have been added."
  gem.email = "kj@gfish.com"
  gem.authors = ["Kasper Johansen"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require "rspec/core"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList["spec/**/*_spec.rb"]
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
  spec.rcov = true
end

task default: :spec

require "rdoc/task"
Rake::RDocTask.new do |rdoc|
  version = File.exist?("VERSION") ? File.read("VERSION") : ""

  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "active-record-transactioner #{version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

require "best_practice_project"
BestPracticeProject.load_tasks
