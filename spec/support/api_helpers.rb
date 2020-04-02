# frozen_string_literal: true

require "uri"

module Coyote
  module Testing
    # Methods to facilitate writing API request specs
    module ApiHelpers
      # Simple helper for DRY'ing up JSON parsing in request specs
      # @return [ActiveSupport::HashWithIndifferentAccess] the deserialized JSON contained in the response body, suitable for use with jsonapi-rspec matchers
      def json_data
        JSON.parse(response.body, symbolize_names: true).with_indifferent_access
      end

      # @return [Hash<Symbol, String>] contains all links listed in data. keys are relation types, values are HTTP paths
      def jsonapi_link_paths(data)
        data.fetch(:links).inject({}) do |result, (rel, link)|
          result.merge!(rel.to_sym => URI.parse(link).request_uri)
        end
      end
    end
  end
end
