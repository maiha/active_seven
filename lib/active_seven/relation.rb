module ActiveSeven
  class Relation
    attr_reader :entities
    delegate :connection, :table_options, :to=>"ActiveSeven::Base"

    def initialize
      @entities = {}            # "name" => an Entity Class
    end

    ######################################################################
    ### Operations

    def * (other)
      ensure_entity(other)
      unless @entities[other.table_name]
        @entities[other.table_name] = other
        ActiveSeven::Base.auto_migrate(self)
      end
      
      return self
    end

    ######################################################################
    ### Migrations

    def table_name
      @entities.keys.map{|i| i.gsub('\.', '__')}.sort.join('_')
    end

    def migrate(*args)
      Migration.new(self, table_options).migrate *args
    end

    private
      def ensure_entity(other)
        unless other.is_a?(Class) and other.ancestors.include?(ActiveSeven::Base)
          raise TypeError, "expected Entity but got #{other.name rescue other.class}"
        end
      end

    class Migration < Migrations::Migrator
      def foreign_keys
        @entity.entities.values.map &:entity_fk
      end

      def up(&block)
        return unless need?(:up)
        super do |t|
          foreign_keys.each do |name|
            t.column name, :integer
          end
        end
        foreign_keys.each do |name|
          connection.add_index table_name, name
        end
      end

      def down(&block)
        return unless need?(:down)
        foreign_keys.each do |name|
          connection.remove_index table_name, name
        end        
        super
      end
    end
  end
end


