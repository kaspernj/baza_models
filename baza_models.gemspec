# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: baza_models 0.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "baza_models"
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["kaspernj"]
  s.date = "2016-05-05"
  s.description = "ActiveRecord like models for the Baza database framework"
  s.email = "k@spernj.org"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rubocop.yml",
    ".rubocop_todo.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "baza_models.gemspec",
    "lib/baza_models.rb",
    "lib/baza_models/autoloader.rb",
    "lib/baza_models/baza_orm_adapter.rb",
    "lib/baza_models/can_can_adapter.rb",
    "lib/baza_models/class_translation.rb",
    "lib/baza_models/errors.rb",
    "lib/baza_models/helpers.rb",
    "lib/baza_models/helpers/ransacker_helper.rb",
    "lib/baza_models/model.rb",
    "lib/baza_models/model/active_record_column_adapater.rb",
    "lib/baza_models/model/belongs_to_relations.rb",
    "lib/baza_models/model/custom_validations.rb",
    "lib/baza_models/model/delegation.rb",
    "lib/baza_models/model/has_many_relations.rb",
    "lib/baza_models/model/has_one_relations.rb",
    "lib/baza_models/model/manipulation.rb",
    "lib/baza_models/model/queries.rb",
    "lib/baza_models/model/reflection.rb",
    "lib/baza_models/model/scopes.rb",
    "lib/baza_models/model/translation_functionality.rb",
    "lib/baza_models/model/validations.rb",
    "lib/baza_models/query.rb",
    "lib/baza_models/query/inspector.rb",
    "lib/baza_models/query/not.rb",
    "lib/baza_models/query/pagination.rb",
    "lib/baza_models/query/sql_generator.rb",
    "lib/baza_models/ransacker.rb",
    "lib/baza_models/ransacker/relationship_scanner.rb",
    "lib/baza_models/test_database_cleaner.rb",
    "lib/baza_models/validators.rb",
    "lib/baza_models/validators/base_validator.rb",
    "lib/baza_models/validators/confirmation_validator.rb",
    "lib/baza_models/validators/format_validator.rb",
    "lib/baza_models/validators/length_validator.rb",
    "lib/baza_models/validators/presence_validator.rb",
    "lib/baza_models/validators/uniqueness_validator.rb",
    "shippable.yml",
    "spec/baza_models/autoloader_spec.rb",
    "spec/baza_models/baza_orm_adapter_spec.rb",
    "spec/baza_models/class_translation_spec.rb",
    "spec/baza_models/factory_girl_spec.rb",
    "spec/baza_models/model/belongs_to_relations_spec.rb",
    "spec/baza_models/model/custom_validations_spec.rb",
    "spec/baza_models/model/delgation_spec.rb",
    "spec/baza_models/model/has_many_relations_spec.rb",
    "spec/baza_models/model/has_one_relations_spec.rb",
    "spec/baza_models/model/manipulation_spec.rb",
    "spec/baza_models/model/queries_spec.rb",
    "spec/baza_models/model/scopes_spec.rb",
    "spec/baza_models/model/translate_functionality_spec.rb",
    "spec/baza_models/model/validations_spec.rb",
    "spec/baza_models/model_spec.rb",
    "spec/baza_models/query/not_spec.rb",
    "spec/baza_models/query/pagination_spec.rb",
    "spec/baza_models/query_spec.rb",
    "spec/baza_models/ransacker_spec.rb",
    "spec/baza_models/validators/confirmation_validator_spec.rb",
    "spec/baza_models/validators/format_validator_spec.rb",
    "spec/baza_models/validators/length_validator_spec.rb",
    "spec/baza_models/validators/uniqueness_validator_spec.rb",
    "spec/baza_models_spec.rb",
    "spec/factories/organization.rb",
    "spec/factories/user.rb",
    "spec/spec_helper.rb",
    "spec/support/database_helper.rb",
    "spec/test_classes/organization.rb",
    "spec/test_classes/person.rb",
    "spec/test_classes/role.rb",
    "spec/test_classes/user.rb",
    "spec/test_classes/user_passport.rb"
  ]
  s.homepage = "http://github.com/kaspernj/baza_models"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "ActiveRecord like models for the Baza database framework"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<array_enumerator>, [">= 0.0.10"])
      s.add_runtime_dependency(%q<baza>, ["~> 0.0.21"])
      s.add_runtime_dependency(%q<string-cases>, [">= 0.0.3"])
      s.add_runtime_dependency(%q<auto_autoloader>, [">= 0.0.1"])
      s.add_runtime_dependency(%q<html_gen>, [">= 0.0.12"])
      s.add_runtime_dependency(%q<simple_delegate>, [">= 0.0.2"])
      s.add_development_dependency(%q<rspec>, ["~> 3.3.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<factory_girl>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<jdbc-sqlite3>, [">= 0"])
      s.add_development_dependency(%q<best_practice_project>, [">= 0"])
      s.add_development_dependency(%q<rubocop>, ["= 0.37.0"])
      s.add_development_dependency(%q<orm_adapter>, [">= 0"])
    else
      s.add_dependency(%q<array_enumerator>, [">= 0.0.10"])
      s.add_dependency(%q<baza>, ["~> 0.0.21"])
      s.add_dependency(%q<string-cases>, [">= 0.0.3"])
      s.add_dependency(%q<auto_autoloader>, [">= 0.0.1"])
      s.add_dependency(%q<html_gen>, [">= 0.0.12"])
      s.add_dependency(%q<simple_delegate>, [">= 0.0.2"])
      s.add_dependency(%q<rspec>, ["~> 3.3.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<factory_girl>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<jdbc-sqlite3>, [">= 0"])
      s.add_dependency(%q<best_practice_project>, [">= 0"])
      s.add_dependency(%q<rubocop>, ["= 0.37.0"])
      s.add_dependency(%q<orm_adapter>, [">= 0"])
    end
  else
    s.add_dependency(%q<array_enumerator>, [">= 0.0.10"])
    s.add_dependency(%q<baza>, ["~> 0.0.21"])
    s.add_dependency(%q<string-cases>, [">= 0.0.3"])
    s.add_dependency(%q<auto_autoloader>, [">= 0.0.1"])
    s.add_dependency(%q<html_gen>, [">= 0.0.12"])
    s.add_dependency(%q<simple_delegate>, [">= 0.0.2"])
    s.add_dependency(%q<rspec>, ["~> 3.3.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<factory_girl>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<jdbc-sqlite3>, [">= 0"])
    s.add_dependency(%q<best_practice_project>, [">= 0"])
    s.add_dependency(%q<rubocop>, ["= 0.37.0"])
    s.add_dependency(%q<orm_adapter>, [">= 0"])
  end
end

