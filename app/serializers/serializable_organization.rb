# frozen_string_literal: true

# JSONAPI serializer for Organizations
class SerializableOrganization < JSONAPI::Serializable::Resource
  type "organization"

  attributes :title
end
