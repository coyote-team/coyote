# frozen_string_literal: true

JSONAPI::Rails.configure do |config|
  # # Set a default serializable class mapping.
  # config.jsonapi_class = Hash.new { |h, k|
  #   names = k.to_s.split('::')
  #   klass = names.pop
  #   h[k] = [*names, "Serializable#{klass}"].join('::').safe_constantize
  # }
  #
  # # Set a default serializable class mapping for errors.
  # config.jsonapi_errors_class = Hash.new { |h, k|
  #   names = k.to_s.split('::')
  #   klass = names.pop
  #   h[k] = [*names, "Serializable#{klass}"].join('::').safe_constantize
  # }.tap { |h|
  #   h[:'ActiveModel::Errors'] = JSONAPI::Rails::SerializableActiveModelErrors
  #   h[:Hash] = JSONAPI::Rails::SerializableErrorHash
  # }
  #
  # # Set a default JSON API object.
  # config.jsonapi_object = {
  #   version: '1.0'
  # }
  #
  # # Set default exposures.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_expose = lambda {
  #   { url_helpers: ::Rails.application.routes.url_helpers }
  # }
  #
  # # Set a default pagination scheme.
  # config.jsonapi_pagination = ->(_) { nil }
  config.jsonapi_fields = lambda {
    {
      resource_group:  SerializableResourceGroup::ATTRIBUTES,
      resource_groups: SerializableResourceGroup::ATTRIBUTES,
    }
  }
  config.logger.level = Logger::Severity::WARN
end

ActionController::Renderers.add(:jsonapi_mixed) do |resources, options|
  valid_resources = resources.select(&:valid?)
  invalid_resources = resources - valid_resources

  # Renderer proc is evaluated in the controller context.
  self.content_type ||= Mime[:jsonapi]
  response = JSONAPI::Rails::Railtie::RENDERERS[:jsonapi].render(valid_resources, options, self).as_json

  if invalid_resources.any?
    invalid_response = JSONAPI::Rails::Railtie::RENDERERS[:jsonapi_errors].render(invalid_resources.map(&:errors), options, self).as_json
    response = invalid_response.merge(response)
  end

  response.to_json
end
