require "auto_autoloader"

class BazaModels
  AutoAutoloader.autoload_sub_classes(self, __FILE__)

  class << self
    attr_accessor :primary_db

    def load_can_can
      BazaModels::CanCanAdapter # Loading the model will make CanCan aware because of inherited hook CanCan implements
    end
  end
end
