Gem::Specification.new do |s|
  s.name = "baza_models".freeze
  s.version = "0.0.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["kaspernj".freeze]
  s.date = "2021-10-04"
  s.description = "ActiveRecord like models for the Baza database framework".freeze
  s.email = "k@spernj.org".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.homepage = "http://github.com/kaspernj/baza_models".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "ActiveRecord like models for the Baza database framework".freeze

  s.add_runtime_dependency(%q<array_enumerator>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<auto_autoloader>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<baza>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<html_gen>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<simple_delegate>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<string-cases>.freeze, [">= 0"])
  s.add_development_dependency(%q<best_practice_project>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<factory_bot>.freeze, [">= 0"])
  s.add_development_dependency(%q<jdbc-sqlite3>.freeze, [">= 0"])
  s.add_development_dependency(%q<orm_adapter>.freeze, [">= 0"])
  s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
end
