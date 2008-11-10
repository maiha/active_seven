module ActiveSeven
  module Attributes
    class HasOneAttribute < AttributeProxy
      def update(association)
        association.__send__("#{name}=", value)
        association.save!
      end
    end
  end
end
