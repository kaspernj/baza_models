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

require "juwelier"
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "baza_models"
  gem.homepage = "http://github.com/kaspernj/baza_models"
  gem.license = "MIT"
  gem.summary = %(ActiveRecord like models for the Baza database framework)
  gem.description = %(ActiveRecord like models for the Baza database framework)
  gem.email = "k@spernj.org"
  gem.authors = ["kaspernj"]
  # dependencies defined in Gemfile
end
Juwelier::RubygemsDotOrgTasks.new

require "rspec/core"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList["spec/**/*_spec.rb"]
end

desc "Code coverage detail"
task :simplecov do
  ENV["COVERAGE"] = "true"
  Rake::Task["spec"].execute
end

task default: :spec

require "rdoc/task"
Rake::RDocTask.new do |rdoc|
  version = File.exist?("VERSION") ? File.read("VERSION") : ""

  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "baza_models #{version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

require "best_practice_project"
BestPracticeProject.load_tasks
