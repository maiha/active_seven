module ActiveSeven
  class Status < Where
    def initialize(klass, name, key)
      super(klass)
      self[name] = key
    end

    def entity_query
      where = sanitize_sql(generate)
      "SELECT DISTINCT %s FROM %s WHERE %s" %
        [klass.base.entity_fk, table_name, where]
    end
  end
end


