module Coyote
  # Utility functions for managing Representations
  module Representation
    # Enumerates all states that a Representation can be in, corresponding to the database's
    # resource_status enum
    STATUSES = {
      ready_to_review: 'ready_to_review',
      approved:        'approved',
      not_approved:    'not_approved'
    }.freeze

    # A list of MIME types for which Coyote accepts representations
    # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types
    # @see https://www.iana.org/assignments/media-types/media-types.xhtml
    CONTENT_TYPES = %w[
      text/plain
      text/html
      audio/mp3
      audio/ogg
      audio/midi
      audio/webm
      audio/3gpp
      audio/3gpp2
      image/gif
      image/png
      image/jpeg
      image/tiff
      image/svg+xml
      video/mpeg
      video/ogg
      video/webm
      video/3gpp
      video/3gpp2
    ].freeze
    
    module_function

    # Iterates through all possible statuses
    # @yieldparam human_friendly_status [String]
    # @yieldparam status [Symbol]
    def self.each_status
      STATUSES.each_key do |status|
        yield status.to_s.titleize, status
      end
    end

    # @return [Array<Symbol>] list of all available statuses
    def self.status_names
      STATUSES.keys
    end
  end
end
