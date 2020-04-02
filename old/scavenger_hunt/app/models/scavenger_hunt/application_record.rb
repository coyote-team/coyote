# frozen_string_literal: true

module ScavengerHunt
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    def self.hook(model, *callbacks, &block)
      model.class_eval do
        callbacks.each do |callback|
          send("after_#{callback}", &block)
        end
      end
    end

    def self.position_scope(*args)
      self
    end

    private

    def set_position
      self.position ||= self.class.position_scope(self).count
    end
  end
end
