# frozen_string_literal: true

# JSONAPI serializer for Organizations
class SerializableUser < JSONAPI::Serializable::Resource
  type "user"

  attributes :first_name, :last_name

  has_many :organizations do
    data do
      # Staff yields membership to all active organizations.
      @object.staff? ? Organization.is_active : @object.organizations
    end
  end

  has_many :memberships do
    data do
      # Only return active membership relations
      @object.memberships{ |membership| membership.active }
    end
  end
end
