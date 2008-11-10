module ActiveSeven
  class Where < ScopedAccess::SqlCondition
    attr_reader :klass
    delegate :name, :columns, :entity_fk, :attribute_name, :table_name, :sanitize_sql, :to=>"@klass"
#    delegate :quote_column_name, :to=>"ActiveSeven::Base.connection"

    def initialize(klass, *args)
      super(*args)
      @klass    = klass
      @not      = false
      @positive = nil           # parent object where this is created by NOT operation
    end

    def column_name
      klass.attribute_name
    end

    def equal(value)
      self[attribute_name] = value
    end

    def real_table_name
      klass.table_name
    end

    def join_query(name = nil)
      name  ||= "#{table_name}_entity"
      query = "INNER JOIN ( %s ) AS %s"
      query % [entity_query, name]
    end

    def not_query
      @not ? "NOT " : nil
    end

    def entity_query
      where      = sanitize_sql(generate)
      statement  = "SELECT DISTINCT %s FROM %s WHERE %s%s"
      parameters = [klass.base.entity_fk, table_name, not_query, where]
      statement % parameters
    end

    ######################################################################
    ### Convertions

    def not ;
      if @not ;
        @positive or
          raise RuntimeError, "[BUG] ActiveSeven::Where(#{id}) is negative but doesn't know his positive value."
      else
        dup.send(:go_negative_from, self)
      end
    end

  private
    def go_negative_from(where)
      @not            = true
      @positive       = where
      @concrete_class = nil
      return self
    end

  protected
    def normalize_column_name(name)
      ActiveSeven::Base.connection.quote_column_name(name)
    end

    def concrete_class
      @concrete_class ||= @klass.base & self
    end

    def method_missing(method_id, *arguments)
      concrete_class.__send__ method_id, *arguments
    end
  end
end
