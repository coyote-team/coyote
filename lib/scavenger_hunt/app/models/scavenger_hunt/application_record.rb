module ScavengerHunt
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    def self.position_scope(*args)
      self
    end

    private

    def set_position
      self.position ||= self.class.position_scope(self).count
    end
  end
end
