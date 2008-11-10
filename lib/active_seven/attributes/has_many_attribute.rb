module ActiveSeven
  module Attributes
    class HasManyAttribute < AttributeProxy
      def construct(value)
        Base.__send__(:safe_to_array, value)
      end

      def update(association)
        association.clear
        value.each_with_index do |val, i|
          association.create(name=>val, :pos=>i)
        end
      end
    end
  end
end
