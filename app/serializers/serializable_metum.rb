# frozen_string_literal: true

# JSONAPI serializer for Metum
class SerializableMetum < JSONAPI::Serializable::Resource
  type "metum"

  attributes :name, :instructions
end
