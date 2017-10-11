require 'uri'

module Coyote
  module Testing
    # Methods to facilitate writing API request specs
    module RequestHelpers
      # Simple helper for DRY'ing up JSON parsing in request specs
      # @return [ActiveSupport::HashWithIndifferentAccess] the deserialized JSON contained in the response body, suitable for use with jsonapi-rspec matchers
      def json_data
        @json_data ||= JSON.parse(response.body,symbolize_names: true).with_indifferent_access
      end

      # @return [Hash<Symbol,String>] contains all links listed in data. keys are relation types, values are HTTP paths
      def jsonapi_link_paths(data)
        data.fetch(:links).inject({}) do |result,(rel,link)|
          result.merge!(rel.to_sym => URI.parse(link).request_uri)
        end
      end

      # @param response result of most recent request
      # @return [Hash<Symbol,String>] represents the components of the current response's HTTP Link header
      def link_header_paths(response)
        link_header = response.headers.fetch('Link')
        links = link_header.split(', ')

        links.inject({}) do |result,link| 
          ref = link[/rel="(\w+)"/,1]
          uri_str = link[URI.regexp]
          uri = URI.parse(uri_str)

          result.merge(ref.to_sym => uri.request_uri)
        end
      end
    end
  end
end
