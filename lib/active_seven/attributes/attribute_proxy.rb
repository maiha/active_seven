module ActiveSeven
  module Attributes
    class AttributeProxy
      attr_accessor :name, :association_name, :value

      def initialize(name, association_name, value)
        @name             = name
        @association_name = association_name
        @value            = construct(value)
      end

      def construct(value)
        value
      end

      def update(association)
        raise NotImplementedError
      end
    end
  end
end
