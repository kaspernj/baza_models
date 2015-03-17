class BazaModels
  path = "#{File.realpath(File.dirname(__FILE__))}/baza_models"

  autoload :Errors, "#{path}/errors"
  autoload :Model, "#{path}/model"
  autoload :Query, "#{path}/query"

  class << self
    attr_accessor :primary_db
  end

  class Validators
    path = "#{File.realpath(File.dirname(__FILE__))}/baza_models/validators"

    autoload :BaseValidator, "#{path}/base_validator"
    autoload :PresenceValidator, "#{path}/presence_validator"
  end
end
