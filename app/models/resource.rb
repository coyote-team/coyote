# == Schema Information
#
# Table name: resources
#
#  id                    :bigint(8)        not null, primary key
#  identifier            :string           not null
#  title                 :string           default("Unknown"), not null
#  resource_type         :enum             not null
#  canonical_id          :string           not null
#  source_uri            :string
#  resource_group_id     :bigint(8)        not null
#  organization_id       :bigint(8)        not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  representations_count :integer          default(0), not null
#  priority_flag         :boolean          default(FALSE), not null
#  host_uris             :string           default([]), not null, is an Array
#  ordinality            :integer
#
# Indexes
#
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#  index_resources_on_priority_flag                     (priority_flag)
#  index_resources_on_representations_count             (representations_count)
#  index_resources_on_resource_group_id                 (resource_group_id)
#

# We use the Dublin Core meaning for what a Resource represents:
# "...a resource is anything that has identity. Familiar examples include an electronic document, an image,
# a service (e.g., "today's weather report for Los Angeles"), and a collection of other resources. Not all
# resources are network "retrievable"; e.g., human beings, corporations, and bound books in a library can also be considered resources."
# @see http://dublincore.org/documents/dc-xml-guidelines/
# @see Coyote::Resource::TYPES
class Resource < ApplicationRecord
  before_save :set_canonical_id
  before_save :set_identifier

  belongs_to :resource_group, inverse_of: :resources
  belongs_to :organization, inverse_of: :resources

  has_many :representations, inverse_of: :resource
  has_many :approved_representations, ->() { approved }, class_name: :Representation
  has_many :subject_resource_links, foreign_key: :subject_resource_id, class_name: :ResourceLink, inverse_of: :subject_resource
  has_many :object_resource_links,  foreign_key: :object_resource_id,  class_name: :ResourceLink, inverse_of: :object_resource
  has_many :assignments, inverse_of: :resource
  has_many :meta, through: :representations

  has_one_attached :uploaded_resource

  scope :represented,              -> { joins(:representations).distinct }
  scope :unrepresented,            -> { left_outer_joins(:representations).where(representations: { resource_id: nil }) }
  scope :assigned,                 -> { joins(:assignments) }
  scope :unassigned,               -> { left_outer_joins(:assignments).where(assignments: { resource_id: nil }) }
  scope :assigned_unrepresented,   -> { unrepresented.joins(:assignments) }
  scope :unassigned_unrepresented, -> { unrepresented.left_outer_joins(:assignments).where(assignments: { resource_id: nil }) }
  scope :by_priority,              -> { order('priority_flag DESC') }
  scope :represented_by, -> (user) { joins(:representations).where(representations: { author_id: user.id }) }

  validates :identifier, uniqueness: true
  validates :resource_type, presence: true
  #validates :canonical_id, presence: true, uniqueness: { scope: :organization_id }
  validates :title, presence: true

  enum resource_type: Coyote::Resource::TYPES

  audited

  paginates_per Rails.configuration.x.resource_api_page_size # see https://github.com/kaminari/kaminari#configuring-max-per_page-value-for-each-model-by-max_paginates_per
  max_paginates_per Rails.configuration.x.resource_api_page_size # see https://github.com/kaminari/kaminari#configuring-max-per_page-value-for-each-model-by-max_paginates_per

  delegate :title, to: :resource_group, prefix: true

  # @see https://github.com/activerecord-hackery/ransack#using-scopesclass-methods
  def self.ransackable_scopes(_ = nil)
    %i[represented assigned unassigned unrepresented assigned_unrepresented unassigned_unrepresented]
  end

  # @return [ActiveSupport::TimeWithZone] if one more resources exist, this is the created_at time for the most recently-created resource
  # @return [nil] if no resources exist
  def self.latest_timestamp
    order(:created_at).last.try(:created_at)
  end

  # @param value [String] a newline-delimited list of host URIs to store for this Resource
  def host_uris=(value)
    write_attribute(:host_uris, value.to_s.split(/[\r\n]+/))
  end

  def viewable?
    (source_uri.present? || uploaded_resource.attached?) && Coyote::Resource::IMAGE_LIKE_TYPES.include?(resource_type.to_sym)
  end

  # @return [String] a human-friendly means of identifying this resource in titles and select boxes
  def label
    "#{title} (#{identifier})"
  end

  # @return [Array<Symbol, ResourceLink, Resource>]
  #   each triplet represents a resource that is linked to this resource, with verbs given
  #   from this resource's perspective
  def related_resources
    result = []

    subject_resource_links.each do |link|
      result << [link.verb, link, link.object_resource]
    end

    object_resource_links.each do |link|
      result << [link.reverse_verb, link, link.subject_resource]
    end

    result
  end

  # TODO: Should maybe move this stuff to a presenter / decorator
  # Status identifiers
  def statuses
    @statuses ||= [].tap do |statuses|
      statuses.push(:urgent) if priority_flag?
      statuses.push(:unrepresented) if unrepresented?
      statuses.push(:represented) if represented?
      statuses.push(:unassigned) if unassigned?
      statuses.push(:assigned) if assigned?
      statuses.push(:partially_complete) if partially_complete?
    end
  end

  def best_representation
    return @best_representation if defined? @best_representation
    @best_representation = representations.by_status.by_title_length.first
  end

  def approved?
    return @approved if defined? @approved
    @approved = complete? && representations.all?(&:approved?)
  end

  def complete?
    return @complete if defined? @complete
    @complete = representations.count >= organization.meta.count
  end

  def partially_complete?
    return @partially_complete if defined? @partially_complete
    @partially_complete = represented? && !complete?
  end

  def unrepresented?
    return @unrepresented if defined? @unrepresented
    @unrepresented = representations.none?
  end

  def represented?
    !unrepresented?
  end

  def unassigned?
    return @unassigned if defined? @unassigned
    @unassigned = assignments.none?
  end

  def assigned?
    !unassigned?
  end

  def generate_canonical_id
    self.canonical_id = SecureRandom.uuid
  end

  def set_canonical_id
    return unless canonical_id.blank?
    next while Resource.where(canonical_id: generate_canonical_id).where.not(id: id).any?
  end

  def set_identifier
    return unless identifier.blank?
    root_identifier = title.parameterize
    identifier = root_identifier
    i = 1
    while Resource.where(identifier: identifier).where.not(id: id).any?
      i += 1
      identifier = "#{root_identifier}-#{i}"
    end
    self.identifier = identifier
  end
end
