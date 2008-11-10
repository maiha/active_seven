RAILS_ENV = "test"

$:.unshift File.dirname(__FILE__) + '/../../../../vendor/rails'

require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'

class Test::Unit::TestCase #:nodoc:
  delegate :quote, :quote_column_name, :to=>"ActiveSeven::Base.connection"

  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"

  def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(fixture_path, table_names, {}, &block)
  end

  def self.models(*model_names)
    model_names.each do |model_name|
      first_time = require "#{fixture_path}#{model_name}"
      if first_time
        klass = model_name.to_s.classify.constantize
        klass.migrate :down
        klass.migrate :up
      end
      fixtures model_name.to_s.pluralize
    end
  end
end

ActiveSeven::Base.instantiate_observers
ActiveSeven::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')

require File.dirname(__FILE__) + '/../init'

