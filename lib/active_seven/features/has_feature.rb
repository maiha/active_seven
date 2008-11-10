module ActiveSeven
  module Features
    module HasFeature
      def self.append_features(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def has(*args)
          options = args.optionize :attribute_name, :type
          parse_migration_options(options)

          attribute_name   = options.delete(:attribute_name).to_s
          plural_name      = pluralize_attribute_name(attribute_name)
          association_name = entity_base_name + '_' + plural_name

          options = {:order=>"pos", :dependent=>:destroy}.merge(options)
          klass   = ensure_assciation_class(association_class_name(attribute_name), self, attribute_name)
          attributes[attribute_name.intern] = klass
          has_many(association_name.intern, options)

          association_name_mappings[attribute_name] = association_name
          association_name_mappings[plural_name]    = association_name

          # reader for plural name
          define_method(plural_name){
            send("[]",  plural_name) or
            send("[]=", plural_name, send(association_name).map{|i| i.send(attribute_name)})
          }
          # reader for singular name
          define_method(attribute_name){ send("[]", attribute_name) || send(plural_name).first }

          # setter for plural name
          define_method("#{plural_name}="){|values|
            attribute = Attributes::HasManyAttribute.new(attribute_name, plural_name, values)
            lazily_update_attributes[association_name] = attribute
            send("[]=", plural_name, attribute.value)
          }
          # setter for singular name
          define_method("#{attribute_name}="){|value| send("#{plural_name}=", value) }
        end

        private
          def pluralize_attribute_name(attribute_name)
            attribute_name = attribute_name.to_s
            plural_name    = attribute_name.pluralize

            return plural_name       if plural_name != attribute_name
            return plural_name + "s" if ActiveSeven::Base.force_pluralize
            raise CannotPluralize, attribute_name
          end
      end
    end
  end
end
