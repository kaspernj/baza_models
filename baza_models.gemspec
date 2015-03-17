# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: baza_models 0.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "baza_models"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["kaspernj"]
  s.date = "2015-03-17"
  s.description = "ActiveRecord like models for the Baza database framework"
  s.email = "k@spernj.org"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/baza_models.rb",
    "lib/baza_models/errors.rb",
    "lib/baza_models/model.rb",
    "lib/baza_models/validators/base_validator.rb",
    "lib/baza_models/validators/presence_validator.rb",
    "shippable.yml",
    "spec/baza_models/model_spec.rb",
    "spec/baza_models_spec.rb",
    "spec/spec_helper.rb",
    "spec/test_classes/user_test.rb"
  ]
  s.homepage = "http://github.com/kaspernj/baza_models"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.0"
  s.summary = "ActiveRecord like models for the Baza database framework"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<baza>, ["~> 0.0.15"])
      s.add_runtime_dependency(%q<string-cases>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<baza>, ["~> 0.0.15"])
      s.add_dependency(%q<string-cases>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<baza>, ["~> 0.0.15"])
    s.add_dependency(%q<string-cases>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end
