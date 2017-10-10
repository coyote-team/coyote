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
  has_many :approved_representations, ->() { approved }, :class_name => :Representation
  has_many :subject_resource_links, :foreign_key => :subject_resource_id, :class_name => :ResourceLink, :inverse_of => :subject_resource
  has_many :object_resource_links,  :foreign_key => :object_resource_id,  :class_name => :ResourceLink, :inverse_of => :object_resource
  has_many :assignments, :inverse_of => :resource

  scope :represented,              -> { joins(:representations) }
  scope :assigned,                 -> { joins(:assignments) }
  scope :unassigned,               -> { left_outer_joins(:assignments).where(assignments: { resource_id: nil }) }
  scope :unrepresented,            -> { left_outer_joins(:representations).where(representations: { resource_id: nil }) }
  scope :assigned_unrepresented,   -> { unrepresented.joins(:assignments) }
  scope :unassigned_unrepresented, -> { unrepresented.left_outer_joins(:assignments).where(assignments: { resource_id: nil }) }
  scope :by_id,                    -> { order(:id) }
  
  validates :identifier, presence: true, uniqueness: true
  validates :resource_type, presence: true
  validates :canonical_id, presence: true, uniqueness: { :scope => :organization_id } 

  enum resource_type: Coyote::Resource::TYPES

  audited
  max_paginates_per Rails.configuration.x.resource_api_page_size # see https://github.com/kaminari/kaminari#configuring-max-per_page-value-for-each-model-by-max_paginates_per

  delegate :title, :to => :context, :prefix => true

  # @return [ActiveSupport::TimeWithZone] if one more resources exist, this is the created_at time for the most recently-created resource
  # @return [nil] if no resources exist
  def self.latest_timestamp
    order(:created_at).last.try(:created_at)
  end

  # Yields to the caller if this resource is image-like, and is capable of being displayed as a static image
  # @yieldparam uri [URI] location of the image file
  # @note Will not yield if the resource is image-like, yet we we are missing a URI
  # @see Coyote::Resource::IMAGE_LIKE_TYPES
  def as_viewable
    return if source_uri.blank?
    yield source_uri if Coyote::Resource::IMAGE_LIKE_TYPES.include?(resource_type.to_sym)
  end

  # @return [String] a human-friendly means of identifying this resource in titles and select boxes
  def label
    "#{title} (#{identifier})"
  end

  # @return [Array<Symbol,ResourceLink,Resource>] 
  #   each triplet represents a resource that is linked to this resource, with verbs given
  #   from this resource's perspective
  def related_resources
    result = []

    subject_resource_links.each do |link|
      result << [link.verb,link,link.object_resource]
    end

    object_resource_links.each do |link|
      result << [link.reverse_verb,link,link.subject_resource]
    end

    result
  end
end
