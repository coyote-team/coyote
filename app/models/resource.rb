# == Schema Information
#
# Table name: resources
#
#  id              :integer          not null, primary key
#  identifier      :string           not null
#  title           :string           default("Unknown"), not null
#  resource_type   :enum             not null
#  canonical_id    :string           not null
#  source_uri      :string
#  context_id      :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_resources_on_context_id                        (context_id)
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#

# We use the Dublin Core meaning for what a Resource represents:
# "...a resource is anything that has identity. Familiar examples include an electronic document, an image, 
# a service (e.g., "today's weather report for Los Angeles"), and a collection of other resources. Not all 
# resources are network "retrievable"; e.g., human beings, corporations, and bound books in a library can also be considered resources."
# @see http://dublincore.org/documents/dc-xml-guidelines/
# @see Coyote::Resource::TYPES
class Resource < ApplicationRecord
  belongs_to :context, :inverse_of => :resources
  belongs_to :organization, :inverse_of => :resources

  has_many :representations, :inverse_of => :resource

  validates :identifier, presence: true, uniqueness: true
  validates :resource_type, presence: true
  validates :canonical_id, presence: true, uniqueness: { :scope => :organization_id } 

  enum resource_type: Coyote::Resource::TYPES

  # Yields to the caller if this resource is image-like, and is capable of being displayed as a static image
  # @yieldparam uri [URI] location of the image file
  # @note Will not yield if the resource is image-like, yet we we are missing a URI
  # @see Coyote::Resource::IMAGE_LIKE_TYPES
  def as_viewable
    return if source_uri.blank?
    yield source_uri if Coyote::Resource::IMAGE_LIKE_TYPES.include?(resource_type.to_sym)
  end
end
