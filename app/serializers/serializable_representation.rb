# frozen_string_literal: true

# JSONAPI serializer for Representations
class SerializableRepresentation < JSONAPI::Serializable::Resource
  type "representation"

  attributes :status, :content_uri, :content_type, :language, :text, :created_at, :updated_at

  attribute :metum do
    @object.metum_name
  end

  attribute :author do
    @object.author_name
  end

  attribute :license do
    @object.license_name
  end

  belongs_to :resource

  link :self do
    # @url_helpers.api_representation_url(@object.id)
  end
end
