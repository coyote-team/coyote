# frozen_string_literal: true

# JSONAPI serializer for Organizations
class SerializableUser < JSONAPI::Serializable::Resource
  type "user"

  attributes :first_name, :last_name

  relationship :organizations
end
