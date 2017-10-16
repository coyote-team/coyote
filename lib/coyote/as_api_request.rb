module Coyote
  # Routing constraint that matches Coyote API requests
  # @see https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-three#toc-versioning
  class AsApiRequest
    # @param version [String] which version we should match - v1, v2, etc.
    def initialize(version)
      @mime_type = format(Rails.configuration.x.api_mime_type_template,version: version)
    end

    # @param request [ActionDispatch::Request] passed in by the Rails router
    # @return [Boolean] whether this is an API request
    def matches?(request)
      accept = request.headers[:accept].to_s
      accept.include?(mime_type)
    end

    private

    attr_reader :mime_type
  end
end
