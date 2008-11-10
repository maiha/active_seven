module ActiveSeven
  delegate :logger, :to=>"ActiveSeven::Base"
  delegate :debug,  :to=>"logger"

  module_function :debug, :logger

  class Error < RuntimeError; end
  class CannotPluralize < Error; end

  class Base < ActiveRecord::Base
    self.abstract_class = true
    self.logger         = ActiveRecord::Base.logger
    self.observers      = ActiveSeven::AssociationObserver

    dsl_accessor :auto_migration,  :default=>true
    dsl_accessor :force_pluralize, :default=>true

    include ActiveSeven::Entity
    include ActiveSeven::Joinable
    include ActiveSeven::Features::HasFeature
    include ActiveSeven::Features::MaskFeature
    include ActiveSeven::Features::StatusFeature
    include ActiveSeven::Migrations::Feature
    include ActiveSeven::RelationalOperation

  end
end




