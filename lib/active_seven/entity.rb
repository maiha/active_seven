module ActiveSeven
  module Entity
    def self.append_features(base)
      base.__send__ :extend,  ClassMethods
      base.__send__ :include, InstanceMethods
      define_class_accessor(base)
    end

    def self.define_class_accessor(base)
      base.class_eval do
        dsl_accessor :base,              :default=>proc{|k| k.root_active_seven}
        dsl_accessor :entity_class_name, :default=>proc{|k| k.name.demodulize}
        dsl_accessor :entity_base_name,  :default=>proc{|k| k.entity_class_name.underscore.gsub('/','_')}
        dsl_accessor :entity_table_name, :default=>proc{|k| k.entity_base_name.tableize}
        dsl_accessor :entity_fk,         :default=>proc{|k| k.entity_base_name + "_id"}
        dsl_accessor :attributes,        :default=>proc{|k| ActiveSupport::OrderedHash.new }
        dsl_accessor :association_name_mappings, :default=>{}
      end
    end

    module InstanceMethods
      def save_associations
        lazily_update_attributes.each do |association_name, attribute|
          returning send(association_name) do |association|
            attribute.update(association)
          end
        end
      end

      def column_for_attribute(name)
        proxy = self.class.attributes[name.to_s.intern]
        if proxy
          proxy.column
        else
          super
        end
      end
    protected
      def lazily_update_attributes
        @lazily_update_attributes ||= {}
      end
    end

    module ClassMethods
      def root_active_seven
        (ancestors - ActiveSeven::Base.ancestors).last
      end

      def association_class_name(attribute_name)
        base.name.demodulize + attribute_name.to_s.camelize
      end

      def association_class(attribute_name)
        association_class_name(attribute_name).constantize
      rescue
        raise NameError, "unknown association: %s" % attribute_name
      end

      def content_columns
        attributes.values.map &:column
      end

      def new_attribute(base, name)
        returning Class.new(AttributeClass) do |klass|
          klass.base base
          klass.attribute_name name
        end
      end

    private
      def ensure_assciation_class(class_name, base, name)
        class_name.constantize
      rescue NameError
        klass = Object.const_set class_name, new_attribute(base, name)
        klass.belongs_to entity_base_name.intern, :class_name=>base.name, :foreign_key=>entity_fk
        ActiveSeven.debug "%s class is automatically created by attribute: %s#%s" % [klass, base, name]
        ActiveSeven::Base.auto_migrate(base)
        return klass
      end

      def resolve_association_name(name)
        case name
        when Array
          name.map{|i| resolve_association_name(i)}
        when Hash
          name.inject({}){|h,(k,v)| h[resolve_association_name(k) || k] = v; h}
        when Symbol, String
          association_name_mappings[name.to_s] || name.to_s
        else
          name
        end
      end

      def merge_includes(first, second)
        super(resolve_association_name(first), resolve_association_name(second))
      end
    end
  end
end
