require 'uri'

module Coyote
  module Testing
    # Methods to facilitate writing API request specs
    module RequestHelpers
      # Simple helper for DRY'ing up JSON parsing in request specs
      # @return [Hash] the deserialized JSON contained in the response body, with names symbolized
      def json_data
        JSON.parse(response.body,symbolize_names: true)
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
