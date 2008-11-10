
require File.dirname(__FILE__) + '/lib/named_options'
require File.dirname(__FILE__) + '/core_ext/class/dsl_accessor'
require File.dirname(__FILE__) + '/core_ext/array/optionize'


ActiveSeven::Base.instantiate_observers

ActiveRecord::Base.instance_eval do
  def aliased_table_name
    table_name
  end
end

ActiveRecord::Associations::ClassMethods::JoinDependency::JoinBase.class_eval do
  def aliased_table_name
    active_record.aliased_table_name
  end
end


