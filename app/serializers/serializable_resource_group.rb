# frozen_string_literal: true

# JSONAPI serializer for Resources
class SerializableResourceGroup < JSONAPI::Serializable::Resource
  type "resource_group"

  attributes :name, :default, :webhook_uri

  belongs_to :organization

  link :coyote do
    @url_helpers.organization_resource_group_url(
      @object.organization_id,
      @object.id,
    )
  end
end
