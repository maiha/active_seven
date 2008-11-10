module ActiveSeven
  module Migrations
    class Migrator
      delegate :connection, :table_name, :entity_fk, :to=>"@entity"

      def initialize(entity, options = nil)
        @entity = entity
        @table_options = options || @entity.table_options || {}
      end

      def exist?
        connection.tables.include? table_name
      end

      def up(&block)
        connection.create_table table_name, @table_options do |t|
          block.call(t)
        end
      end

      def down(&block)
        connection.drop_table table_name
      end

      def need?(direction = :up)
        guard_against_direction(direction)
        (direction == :up) ^ exist?
      end

      def migrate(direction = :up, &block)
        guard_against_direction(direction)
        __send__ direction, &block
      end

      private
      def guard_against_direction(direction)
        unless [:up, :down].include? direction
          raise ArgmentError, "Valid directions are :up or :down for migration"
        end
      end
    end

    class EntityTable < Migrator
      def up
        super do |t|
          t.__send__ :column, :created_at, :datetime
          t.__send__ :column, :updated_at, :datetime
        end
      end
    end

    class AssociationTable < Migrator
      def initialize(entity, column_name, column_options, table_options = nil)
        super(entity, table_options)
        @name    = column_name.to_s
        @options = column_options
      end

      def table_name
        [@entity.entity_base_name, @name.pluralize] * '_'
      end

      def up
        super do |t|
          t.__send__ :column, entity_fk, :integer
          t.__send__ :column, @name, *@options
          t.__send__ :column, :pos, :integer
        end
        connection.add_index table_name, entity_fk
      end
    end

    class StatusTable < AssociationTable
      def up(&block)
        connection.create_table table_name, @table_options do |t|
          t.__send__ :column, entity_fk, :integer
          t.__send__ :column, @name, *@options
        end
        connection.add_index table_name, entity_fk
        connection.add_index table_name, @name
      end
    end

    class MaskTable < StatusTable
    end
  end
end
