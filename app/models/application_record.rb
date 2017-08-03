# @abstract This is the base class for all app models, required for Rails 5
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
