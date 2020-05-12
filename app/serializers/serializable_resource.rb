# frozen_string_literal: true

# JSONAPI serializer for Resources
class SerializableResource < JSONAPI::Serializable::Resource
  type "resource"

  attributes :id, :name, :resource_type, :canonical_id, :source_uri, :created_at, :updated_at

  attribute :resource_group do
    @object.resource_group_name
  end

  belongs_to :organization

  has_many :resource_groups

  has_many :representations do
    data do
      @object.approved_representations
    end
  end

  link :coyote do
    @url_helpers.resource_url(@object.id)
  end
end
