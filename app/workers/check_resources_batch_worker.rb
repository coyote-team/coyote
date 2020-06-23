# frozen_string_literal: true

class CheckResourcesBatchWorker < ApplicationWorker
  def perform(resource_id)
    resource = Resource.find(resource_id)

    client = Faraday.new(url: resource.source_uri)

    # Check the resource status
    begin
      response = client.head.status
    rescue Faraday::ConnectionFailed
      response = 404
    end

    resource.status_checks.create!(
      response:   response,
      source_uri: resource.source_uri,
    )

    # Update the resource's status based on the response
    new_status = case response
    when 200..299
      :active
    when 400..499
      :not_found
    else
      :unexpected_response
    end

    resource.update_attribute(:status, new_status)
  end
end
