module Coyote
  # Utility functions for managing Resources
  module Resource
    # Categories to which a resource can belong, corresponding to the resource_type database enum
    # @see http://dublincore.org/documents/dcmi-terms/
    TYPES = {
      collection:           'collection',
      dataset:              'dataset',
      event:                'event',
      image:                'image',
      interactive_resource: 'interactive_resource',
      moving_image:         'moving_image',
      physical_object:      'physical_object',
      service:              'service', 
      software:             'software',
      sound:                'sound',
      still_image:          'still_image',
      text:                 'text'
    }.freeze

    IMAGE_LIKE_TYPES = %i[image moving_image still_image].freeze

    module_function

    # Iterates through all possible Resource types
    # @yieldparam human_friendly_type [String]
    # @yieldparam type [Symbol]
    def self.each_type
      TYPES.each_key do |type|
        yield type.to_s.titleize, type
      end
    end

    # @return [Array<Symbol>] list of all available types
    def self.type_names
      TYPES.keys
    end
  end
end
