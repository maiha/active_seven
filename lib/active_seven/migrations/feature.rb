require File.dirname(__FILE__) + '/migrator'

module ActiveSeven
  module Migrations
    AssociationSchema = Struct.new(:name, :class, :column_options, :table_options)

    module Feature
      def self.append_features(base)
        base.extend ClassMethods
        base.class_eval do
          dsl_accessor :table_options, :default=>{}
          dsl_accessor :association_column_schemas, :default=>[]
        end
      end

      module ClassMethods
        def migrate(*args)
          options       = args.optionize(:direction, :options)
          direction     = options[:direction] || :up
          table_options = options[:options]   || self.table_options || {}
          tables        = []

          tables << EntityTable.new(self, table_options)
          association_column_schemas.each do |schema|
            tables << schema.class.new(self, schema.name, schema.column_options, schema.table_options)
          end

          returning executeds = [] do
            tables.each do |migration|
              next unless migration.need?(direction)
              migration.migrate(direction)
              executeds << migration.table_name
            end
          end
        end

        def auto_migrate(*classes)
          if auto_migration
            classes.each do |klass|
              klass.migrate
            end
          end
        end

        private

        def parse_migration_options(options)
          #        ActiveSeven.debug "parse_migration_options(%s, %s)" % [args.inspect, options.inspect]
          type   = options.delete(:type)
          column = options.delete(:column)

          if type
            case column
            when Array
              column[0] = type
            when NilClass
              column = type
            else
              raise TypeError, "migration column should be Array"
            end
          end

          if column
            attribute_name = options[:attribute_name]
            klass          = options.delete(:migrate_schema) || AssociationTable
            table_options  = options.delete(:table_options)
            association_column_schemas << AssociationSchema.new(attribute_name, klass, column, table_options)
          end
        end
      end
    end
  end
end
