module BazaModels::Model::Delegation
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def delegate(*methods, args)
      methods.each do |method|
        if args[:prefix]
          method_name = "#{args.fetch(:to)}_#{method}"
        else
          method_name = method
        end

        define_method(method_name) do |*method_args, &method_blk|
          __send__(args[:to]).__send__(method, *method_args, &method_blk)
        end
      end
    end
  end
end
