# frozen_string_literal: true

class SerializableMembership < JSONAPI::Serializable::Resource
  type "membership"

  attributes :active, :first_name, :last_name, :email, :role
end
