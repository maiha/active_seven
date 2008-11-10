module ActiveSeven
  module Joinable
    def self.[](base, name = nil)
      new_class(base, name)
    end

    def self.new_class(base, name)
      klass = Class.new(base)
      klass.__send__ :include, Joinable
      klass.base = base
      klass.attribute_name = name
      return klass
    end

    def self.append_features(base)
      base.extend ClassMethods

      base.class_eval do
        dsl_accessor :attribute_name,  :default=>proc{raise NotImplementedError}
        dsl_accessor :join_type,       :default=>"INNER"
        dsl_accessor :joins,           :default=>proc{|k|[k]}
      end
    end

    module ClassMethods

      # overrides ActiveRecord::Base methods

      def aliased_table_name
        real_table_name
      end

      def columns
        unless @columns
          @columns = connection.columns(real_table_name, "#{name} Columns")
          @columns.each {|column| column.primary = column.name == primary_key}
        end
        @columns
      end

      # main methods

      def join_query
        real_table_name
      end

      def real_table_name
        entity_table_name
      end

      def table_name_with_alias
        raise "[AS BUG] joins has no members (#{self.name})" if joins.empty?

        query = ''
        joins.each_with_index do |obj, i|
          name = "t_#{i}"
          if i == 0
            query = obj.join_query.dup
          else
            base = obj.klass.base
            join = obj.join_query(name)
            query << "\n%s ON %s.%s = %s.%s" %
              [join, name, base.entity_fk,
               base.table_name, base.primary_key]
          end
        end
        return query
      end

      def table_name
        table_name_with_alias
      end
    end
  end
end
