# frozen_string_literal: true

# JSONAPI serializer for Resources
class SerializableResourceGroup < JSONAPI::Serializable::Resource
  ATTRIBUTES = %i[name default webhook_uri]
  type "resource_group"

  attributes(*ATTRIBUTES)

  # Token is hidden by default (see config/initializers/jsonapi.rb), since we don't want to expose
  # this anywhere outside of the resource group API endpoint. The resource group API endpoint
  # includes this token attribute. Everywhere else it is ignored.
  attribute :token

  belongs_to :organization

  link :coyote do
    @url_helpers.organization_resource_group_url(
      @object.organization_id,
      @object.id,
    )
  end
end
