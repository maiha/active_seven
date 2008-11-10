module ActiveSeven
  module Features
    module MaskFeature
      def self.append_features(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def masks
          @masks ||= {}
        end

        def mask(*args)
          options = args.optionize :attribute_name, :type

          options[:migrate_schema] ||= Migrations::StatusTable
          options[:dependent]      ||= :destroy
          options[:column]         ||= [:boolean, {:default=>true}]

          parse_migration_options(options)
          attribute_name = options.delete(:attribute_name).to_s

          klass = ensure_assciation_class(association_class_name(attribute_name), self, attribute_name)
          attributes[attribute_name.intern] = klass
          association_name = association_class_name(attribute_name).underscore
          has_one(association_name.intern, options.symbolize_keys)

          association_name_mappings[attribute_name] = association_name

          # reader for singular name
          define_method(attribute_name){
            obj = __send__(association_name) || __send__("build_#{association_name}", attribute_name=>false)
            obj.__send__(attribute_name)
          }

          # setter for singular name
          define_method("#{attribute_name}="){|value|
            attribute = Attributes::HasOneAttribute.new(attribute_name, association_name, value)
            lazily_update_attributes[association_name] = attribute

            # create association by calling getter
            __send__(attribute_name)
            __send__(association_name).__send__("#{attribute_name}=", attribute.value)

            send("[]=", association_name, attribute.value)
          }

          instance_eval <<-CODE
            def #{attribute_name}
              klass = association_class_name(:#{attribute_name}).constantize
              ActiveSeven::Mask.new(klass, '#{attribute_name}', true)
            end
          CODE
        end
      end
    end
  end
end
