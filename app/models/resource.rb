# frozen_string_literal: true

# == Schema Information
#
# Table name: resources
#
#  id                    :bigint           not null, primary key
#  host_uris             :string           default([]), not null, is an Array
#  name                  :string           default("(no title provided)"), not null
#  priority_flag         :boolean          default(FALSE), not null
#  representations_count :integer          default(0), not null
#  resource_type         :enum             not null
#  source_uri            :citext           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  canonical_id          :citext
#  organization_id       :bigint           not null
#
# Indexes
#
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#  index_resources_on_priority_flag                     (priority_flag)
#  index_resources_on_representations_count             (representations_count)
#  index_resources_on_source_uri_and_organization_id    (source_uri,organization_id) UNIQUE WHERE ((source_uri IS NOT NULL) AND (source_uri <> ''::citext))
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => restrict ON UPDATE => cascade
#

# We use the Dublin Core meaning for what a Resource represents:
# "...a resource is anything that has identity. Familiar examples include an electronic document, an image,
# a service (e.g., "today's weather report for Los Angeles"), and a collection of other resources. Not all
# resources are network "retrievable"; e.g., human beings, corporations, and bound books in a library can also be considered resources."
# @see http://dublincore.org/documents/dc-xml-guidelines/
# @see Coyote::Resource::TYPES
class Resource < ApplicationRecord
  DEFAULT_NAME = "(no title provided)"

  before_create :set_default_resource_group

  after_commit :notify_webhook!, if: :content_changed?

  belongs_to :organization, inverse_of: :resources

  has_many :representations, inverse_of: :resource
  has_many :approved_representations, -> { approved }, class_name: :Representation, inverse_of: :resource
  has_many :subject_resource_links, foreign_key: :subject_resource_id, class_name: :ResourceLink, inverse_of: :subject_resource
  has_many :object_resource_links, foreign_key: :object_resource_id, class_name: :ResourceLink, inverse_of: :object_resource
  has_many :assignments, inverse_of: :resource
  has_many :meta, through: :representations

  has_many :resource_group_resources, inverse_of: :resource
  has_many :resource_groups, through: :resource_group_resources, inverse_of: :resources
  has_many :resource_webhook_calls, dependent: :destroy

  has_one_attached :uploaded_resource

  scope :represented, -> { joins(:representations).distinct }
  scope :unrepresented, -> { left_outer_joins(:representations).where(representations: {resource_id: nil}) }
  scope :assigned, -> { joins(:assignments) }
  scope :unassigned, -> { left_outer_joins(:assignments).where(assignments: {resource_id: nil}) }
  scope :assigned_unrepresented, -> { unrepresented.joins(:assignments) }
  scope :unassigned_unrepresented, -> { unrepresented.left_outer_joins(:assignments).where(assignments: {resource_id: nil}) }
  scope :by_date, -> { order(created_at: :desc) }
  scope :by_priority, -> { order(priority_flag: :desc) }
  scope :order_by_priority_and_date, -> { by_priority.by_date }
  scope :represented_by, ->(user) { joins(:representations).where(representations: {author_id: user.id}) }
  scope :with_approved_representations, -> { joins(:representations).where(representations: {status: Coyote::Representation::STATUSES[:approved]}) }

  validates :resource_type, presence: true
  validates :canonical_id, uniqueness: {scope: :organization_id}, allow_blank: true
  validates :source_uri, presence: true, uniqueness: {scope: :organization_id}
  validates :name, presence: true

  enum resource_type: Coyote::Resource::TYPES

  audited

  paginates_per Rails.configuration.x.resource_api_page_size # see https://github.com/kaminari/kaminari#configuring-max-per_page-value-for-each-model-by-max_paginates_per
  # max_paginates_per Rails.configuration.x.resource_api_page_size # see https://github.com/kaminari/kaminari#configuring-max-per_page-value-for-each-model-by-max_paginates_per

  delegate :name, to: :resource_group, prefix: true

  # @return [ActiveSupport::TimeWithZone] if one more resources exist, this is the created_at time for the most recently-created resource
  # @return [nil] if no resources exist
  def self.latest_timestamp
    order(:created_at).last.try(:created_at)
  end

  # @see https://github.com/activerecord-hackery/ransack#using-scopesclass-methods
  def self.ransackable_scopes(_ = nil)
    %i[order_by_priority_and_date represented assigned unassigned unrepresented assigned_unrepresented unassigned_unrepresented with_approved_representations]
  end

  def approved?
    return @approved if defined? @approved
    @approved = complete? && representations.all?(&:approved?)
  end

  def assigned?
    !unassigned?
  end

  def best_representation
    return @best_representation if defined? @best_representation
    @best_representation = representations.by_status.by_length.first
  end

  def complete?
    return @complete if defined? @complete
    @complete = representations.count >= organization.meta.count
  end

  def content_changed?
    (previous_changes.keys & %w[name resource_type canonical_id source_uri priority_flag host_uris]).any?
  end

  # @param value [String] a newline-delimited list of host URIs to store for this Resource
  def host_uris=(value)
    self[:host_uris] = value.to_s.split(/[\r\n]+/)
  end

  # @return [String] a human-friendly means of identifying this resource in names and select boxes
  def label
    @label ||= canonical_id.present? ? "#{name} (#{canonical_id})" : name
  end

  def notify_webhook!
    NotifyWebhookWorker.perform_async(id) if resource_groups.has_webhook.any?
  end

  def partially_complete?
    return @partially_complete if defined? @partially_complete
    @partially_complete = represented? && !complete?
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

  def representations_attributes=(representations_attributes)
    representations_attributes.each do |attributes|
      attributes = attributes.with_indifferent_access
      representation = representations.find_or_initialize_by(attributes.slice(:language, :text))

      if representation.new_record?
        # Set the author_id if it needs to be set
        attributes[:author_id] ||= organization.memberships.active.by_creation.first_id(:user_id)

        # Increase ordinality for new representations when there are other representations this metum
        attributes[:ordinality] = representations.where.not(id: representation.id).with_metum(attributes[:metum_id]).count
      end

      # Allow assigning license by name, e.g. "cc0-1.0"
      representation.select_default_license(attributes)

      # Allow assigning metum by name, e.g. "Short" or "Long"
      representation.select_default_metum(attributes, organization.meta)

      # Assign whatever is left
      representation.assign_attributes(attributes)
    end
  end

  def represented?
    !unrepresented?
  end

  def resource_group
    @resource_group ||= resource_groups.first
  end

  # def resource_group=(new_resource_group)
  #   resource_group_resources << resource_group_resources.find_or_initialize_by(resource_group: new_resource_group)
  # end

  # def resource_group_id
  #   resource_groups_ids.first
  # end

  def resource_group_id=(new_resource_group_id)
    resource_group = new_resource_group_id.presence && organization.resource_groups.find_by(id: new_resource_group_id)
    resource_groups << resource_group if resource_group.present? && !resource_group_ids.include?(resource_group.id)
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

  def unassigned?
    return @unassigned if defined? @unassigned
    @unassigned = assignments.none?
  end

  def unrepresented?
    return @unrepresented if defined? @unrepresented
    @unrepresented = representations.none?
  end

  def viewable?
    (source_uri.present? || uploaded_resource.attached?) && Coyote::Resource::IMAGE_LIKE_TYPES.include?(resource_type&.to_sym)
  end

  private

  def set_default_resource_group
    resource_groups << organization.resource_groups.default.first unless resource_groups.any?
  end
end
