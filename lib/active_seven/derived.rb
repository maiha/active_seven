module ActiveSeven
  module Derived
    def self.append_features(base)
      base.__send__ :extend,  ClassMethods
    end

    module ClassMethods
      def instantiate(record)
        base_class.instantiate(record)
      end
    end
  end
end
