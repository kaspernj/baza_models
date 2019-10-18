# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: baza_models 0.0.13 ruby lib

Gem::Specification.new do |s|
  s.name = "baza_models".freeze
  s.version = "0.0.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["kaspernj".freeze]
  s.date = "2019-10-18"
  s.description = "ActiveRecord like models for the Baza database framework".freeze
  s.email = "k@spernj.org".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rubocop.yml",
    ".rubocop_todo.yml",
    ".ruby-version",
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
    "lib/baza_models/ransacker/context.rb",
    "lib/baza_models/ransacker/relationship_scanner.rb",
    "lib/baza_models/test_database_cleaner.rb",
    "lib/baza_models/validators.rb",
    "lib/baza_models/validators/base_validator.rb",
    "lib/baza_models/validators/confirmation_validator.rb",
    "lib/baza_models/validators/format_validator.rb",
    "lib/baza_models/validators/length_validator.rb",
    "lib/baza_models/validators/presence_validator.rb",
    "lib/baza_models/validators/uniqueness_validator.rb",
    "peak_flow.yml",
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
  s.homepage = "http://github.com/kaspernj/baza_models".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "ActiveRecord like models for the Baza database framework".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<array_enumerator>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<auto_autoloader>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<baza>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<html_gen>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<simple_delegate>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<string-cases>.freeze, [">= 0"])
      s.add_development_dependency(%q<best_practice_project>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<factory_girl>.freeze, [">= 0"])
      s.add_development_dependency(%q<jdbc-sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 0"])
      s.add_development_dependency(%q<orm_adapter>.freeze, [">= 0"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    else
      s.add_dependency(%q<array_enumerator>.freeze, [">= 0"])
      s.add_dependency(%q<auto_autoloader>.freeze, [">= 0"])
      s.add_dependency(%q<baza>.freeze, [">= 0"])
      s.add_dependency(%q<html_gen>.freeze, [">= 0"])
      s.add_dependency(%q<simple_delegate>.freeze, [">= 0"])
      s.add_dependency(%q<string-cases>.freeze, [">= 0"])
      s.add_dependency(%q<best_practice_project>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<factory_girl>.freeze, [">= 0"])
      s.add_dependency(%q<jdbc-sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<jeweler>.freeze, [">= 0"])
      s.add_dependency(%q<orm_adapter>.freeze, [">= 0"])
      s.add_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<array_enumerator>.freeze, [">= 0"])
    s.add_dependency(%q<auto_autoloader>.freeze, [">= 0"])
    s.add_dependency(%q<baza>.freeze, [">= 0"])
    s.add_dependency(%q<html_gen>.freeze, [">= 0"])
    s.add_dependency(%q<simple_delegate>.freeze, [">= 0"])
    s.add_dependency(%q<string-cases>.freeze, [">= 0"])
    s.add_dependency(%q<best_practice_project>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<factory_girl>.freeze, [">= 0"])
    s.add_dependency(%q<jdbc-sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<jeweler>.freeze, [">= 0"])
    s.add_dependency(%q<orm_adapter>.freeze, [">= 0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end

