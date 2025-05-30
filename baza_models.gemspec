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

  s.add_runtime_dependency "array_enumerator", ">= 0"
  s.add_runtime_dependency "auto_autoloader", ">= 0"
  s.add_runtime_dependency "baza", ">= 0"
  s.add_runtime_dependency "html_gen", ">= 0"
  s.add_runtime_dependency "simple_delegate", ">= 0"
  s.add_runtime_dependency "string-cases", ">= 0"
  s.add_runtime_dependency "wref", ">= 0.0.11"
end
