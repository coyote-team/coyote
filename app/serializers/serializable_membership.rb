# frozen_string_literal: true

class SerializableMembership < JSONAPI::Serializable::Resource
  type "membership"

  attributes :active, :first_name, :last_name, :email, :role

  attribute :organization_id do
    # Map integer to string for response consistency
    @object.organization_id.to_s
  end
end
