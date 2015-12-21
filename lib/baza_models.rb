class BazaModels
  path = "#{File.realpath(File.dirname(__FILE__))}/baza_models"

  autoload :Autoloader, "#{path}/autoloader"
  autoload :BazaOrmAdapter, "#{path}/baza_orm_adapter"
  autoload :ClassTranslation, "#{path}/class_translation"
  autoload :Errors, "#{path}/errors"
  autoload :Model, "#{path}/model"
  autoload :Ransacker, "#{path}/ransacker"
  autoload :Query, "#{path}/query"

  class << self
    attr_accessor :primary_db
  end

  class Validators
    path = "#{File.realpath(File.dirname(__FILE__))}/baza_models/validators"

    autoload :BaseValidator, "#{path}/base_validator"
    autoload :ConfirmationValidator, "#{path}/confirmation_validator"
    autoload :FormatValidator, "#{path}/format_validator"
    autoload :LengthValidator, "#{path}/length_validator"
    autoload :PresenceValidator, "#{path}/presence_validator"
    autoload :UniquenessValidator, "#{path}/uniqueness_validator"
  end
end
