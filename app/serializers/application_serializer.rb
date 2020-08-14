# frozen_string_literal: true

class ApplicationSerializer < JSONAPI::Serializable::Resource
  def self.url(helper, *args)
    routes = Rails.application.routes.url_helpers
    routes&.respond_to?(helper, true) ? routes.send(helper, *args) : nil
  end
end
