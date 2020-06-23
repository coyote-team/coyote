# frozen_string_literal: true

module Coyote
  # Utility functions for managing Resources
  module Resource
    # Enumerates all states that a Resource can be in, corresponding to the database's
    # resource_status enum
    STATUSES = {
      active:              "active",
      archived:            "archived",
      deleted:             "deleted",
      not_found:           "not_found",
      unexpected_response: "unexpected_response",
    }.freeze

    # Categories to which a resource can belong, corresponding to the resource_type database enum
    # @see http://dublincore.org/documents/dcmi-terms/
    TYPES = {
      # collection:           "collection",
      # dataset:              "dataset",
      # event:                "event",
      image: "image",
      # interactive_resource: "interactive_resource",
      # moving_image:         "moving_image",
      # physical_object:      "physical_object",
      # service:              "service",
      # software:             "software",
      # sound:                "sound",
      # still_image:          "still_image",
      # text:                 "text",
    }.freeze

    IMAGE_LIKE_TYPES = %i[image moving_image still_image].freeze

    module_function

    # @return [Array<Symbol>] list of all available types
    def self.type_names
      TYPES.keys
    end
  end
end
