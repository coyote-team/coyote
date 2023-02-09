# frozen_string_literal: true

# JSONAPI serializer for Resources
class SerializableResource < ApplicationSerializer
  type "resource"

  attributes :id, :name, :resource_type, :host_uris, :canonical_id, :source_uri, :created_at, :updated_at

  attribute :resource_group do
    @object.resource_group_name
  end

  belongs_to :organization

  has_many :resource_groups

  has_many :representations do
    data do
      @object.approved_representations.with_distinct_meta
    end
  end

  link :coyote do
    ApplicationSerializer.url(:resource_url, @object.id, organization_id: @object.organization_id)
  end
end
