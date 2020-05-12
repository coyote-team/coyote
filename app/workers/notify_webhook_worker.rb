# frozen_string_literal: true

class NotifyWebhookWorker
  include Cloudtasker::Worker

  cloudtasker_options lock: :until_executed, on_conflict: :reject

  attr_reader :resource

  def perform(resource_id)
    @resource = Resource.find(resource_id)
    renderer = JSONAPI::Serializable::Renderer.new
    body = renderer.render(
      resource,
      class:   {
        Organization:   SerializableOrganization,
        Representation: SerializableRepresentation,
        Resource:       SerializableResource,
        ResourceGroup:  SerializableResourceGroup,
        User:           SerializableUser,
      },
      expose:  {
        url_helpers: Rails.application.routes.url_helpers,
      },
      include: %i[organization representations resource_groups],
    )

    resource.resource_groups.has_webhook.each do |resource_group|
      error = nil
      Rails.logger.warn "[WEBHOOK] Calling #{resource_group.webhook_uri} for #{resource}"

      begin
        client = Faraday.new(url: resource_group.webhook_uri)
        response = client.post { |req|
          req.headers["Content-Type"] = "application/json"
          req.body = body.to_json
        }
      rescue => e
        error = e
      ensure
        record_webhook_call(resource_group, body, response, error)
      end
    end
  end

  private

  # :nocov:
  def on_error(error)
    if defined? Raven
      Raven.capture_exception(exception)
    else
      raise error
    end
  end
  # :nocov:

  def record_webhook_call(resource_group, body, response, error)
    attributes = {
      body:     body,
      response: response&.status,
      uri:      resource_group.webhook_uri,
    }

    attributes[:error] = error.message if error

    resource.resource_webhook_calls.create!(attributes)
    raise error if error.present?
  end
end
