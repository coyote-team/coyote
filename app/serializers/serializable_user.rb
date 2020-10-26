# frozen_string_literal: true

# JSONAPI serializer for Organizations
class SerializableUser < JSONAPI::Serializable::Resource
  type "user"

  attributes :first_name, :last_name

  has_many :organizations do
    data do
      @object.staff? ? Organization.is_active : @object.organizations
    end
  end
end
