class BazaModels
  path = "#{File.realpath(File.dirname(__FILE__))}/baza_models"

  autoload :Model, "#{path}/model"

  class << self
    attr_accessor :primary_db
  end

  class Validators
    path = "#{File.realpath(File.dirname(__FILE__))}/baza_models/validators"

    autoload :PresenceValidator, "#{path}/presence"
  end
end
