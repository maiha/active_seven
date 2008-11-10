module ActiveSeven
  class AssociationObserver < ActiveRecord::Observer
    def self.observed_class() Base end

    def after_save(record)
      record.save_associations
      true
    end
  end
end

