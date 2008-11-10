module ActiveSeven
  class AttributeClass < Base
    include Joinable

    dsl_accessor :base, :default=>nil
    dsl_accessor :attribute_name, :default=>nil

    class << self
      def column
        columns_hash[attribute_name.to_s]
      end
    end
  end
end
