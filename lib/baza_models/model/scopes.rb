module BazaModels::Model::Scopes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def scope(name, blk)
      @scopes ||= {}
      name = name.to_sym

      raise "Such a scope already exists" if @scopes.key?(name)
      @scopes[name] = {blk: blk}

      (class << self; self; end).__send__(:define_method, name) do
        blk.call
      end
    end
  end
end
