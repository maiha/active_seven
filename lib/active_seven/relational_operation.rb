module ActiveSeven
  module RelationalOperation
    def self.append_features(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def &(other)
        case other
        when Where, Joinable
          klass = Class.new(self)
          klass.module_eval do
            include Derived
            joins(joins + [other])
          end
          return klass
        when Array
          other.inject(self){|r, t| r & t}
        when Hash
          self & other.values
        else
          raise TypeError, "Cannot join %s class" % other.class.name
        end
      end

      def *(other)
        if other.is_a?(Class) and other.ancestors.include?(ActiveSeven::Base)
          ActiveSeven::Relation.new * self * other
        else
          raise TypeError, "Cannot relate %s class" % (other.name rescue other.class)
        end
      end

      def where(options)
        case options
        when String, Symbol
          ActiveSeven::Where.new(association_class(options))
        when Hash
          if options.size == 1
            key  = options.keys.min
            val  = options.values.min
            ActiveSeven::Where.new(association_class(key), key=>val)
          else
            options.symbolize_keys.inject({}) do |hash, (key, val)|
              cond = hash[key] ||= where(key)
              cond[key] = val
              hash
            end
          end
        else
          raise TypeError, "where expects String/Symbol/Hash but got #{options.class}"
        end
      end
    end
  end
end


