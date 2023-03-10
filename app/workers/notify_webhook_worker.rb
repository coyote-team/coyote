# frozen_string_literal: true

class NotifyWebhookWorker < ApplicationWorker
  INVALID_REDIRECT_STATUSES = [301, 302, 303]

  class WebhookEndpointRedirectsError < StandardError
    attr_reader :endpoint, :location, :status

    def initialize(endpoint: nil, location: "unknown", status: "unknown")
      super
      @endpoint = endpoint
      @location = location
      @status = status
    end

    def message
      "Webhook endpoint '#{endpoint}' redirected to '#{location}' with status #{status}"
    end
  end

  attr_reader :resource

  def perform(resource_id)
    @resource = Resource.find(resource_id)
    renderer = JSONAPI::Serializable::Renderer.new

    # Generate a JWT token for the request
    payload = {
      id: resource.id.to_s,
    }

    # Generate a JSON body for the request
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
      fields:  {
        resource_group:  SerializableResourceGroup::ATTRIBUTES,
        resource_groups: SerializableResourceGroup::ATTRIBUTES,
      },
      include: %i[organization representations resource_groups],
    )

    resource.resource_groups.has_webhook.each do |resource_group|
      token = JWT.encode(payload, resource_group.token, "HS256")
      error = nil
      Rails.logger.warn "[WEBHOOK] Calling #{resource_group.webhook_uri} for #{resource}"

      begin
        redirect_callback = proc { |old_response, new_response|
          if INVALID_REDIRECT_STATUSES.include?(old_response.status)
            raise WebhookEndpointRedirectsError.new(
              endpoint: old_response.url,
              location: new_response.url,
              status:   old_response.status,
            )
          end
        }

        client = Faraday.new(url: resource_group.webhook_uri) do |f|
          f.use FaradayMiddleware::FollowRedirects, {callback: redirect_callback}
        end

        response = client.post { |req|
          req.headers["Content-Type"] = "application/json"
          req.headers["X-Coyote-Token"] = token
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
