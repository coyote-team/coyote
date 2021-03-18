# frozen_string_literal: true

# == Schema Information
#
# Table name: resources
#
#  id                    :bigint           not null, primary key
#  host_uris             :string           default([]), not null, is an Array
#  is_deleted            :boolean          default(FALSE), not null
#  name                  :string           default("(no title provided)"), not null
#  priority_flag         :boolean          default(FALSE), not null
#  representations_count :integer          default(0), not null
#  resource_type         :enum             default("image"), not null
#  source_uri            :citext           not null
#  source_uri_hash       :string
#  status                :enum             default("active"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  canonical_id          :citext
#  organization_id       :bigint           not null
#
# Indexes
#
#  index_resources_on_canonical_id                      (canonical_id)
#  index_resources_on_is_deleted                        (is_deleted)
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#  index_resources_on_priority_flag                     (priority_flag)
#  index_resources_on_representations_count             (representations_count)
#  index_resources_on_schemaless_source_uri             (source_uri) USING gin
#  index_resources_on_source_uri                        (source_uri)
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
  SKIP_WEBHOOKS_KEY = :skip_webhooks

  attr_accessor :overwrite_representations, :skip_unique_validations, :skip_webhooks,
    :union_host_uris, :union_resource_groups
  attr_reader :assign_to_user_id

  before_save :merge_host_uris
  before_save :merge_resource_groups
  before_save :clear_blank_canonical_ids, if: :canonical_id_changed?
  before_save :set_source_uri_hash, if: :source_uri_changed?
  before_create :set_default_resource_group

  after_commit :notify_webhook!, if: :content_changed?

  belongs_to :organization, inverse_of: :resources

  has_many :representations, inverse_of: :resource, dependent: :destroy
  has_many :approved_representations, -> { approved }, class_name: :Representation, inverse_of: :resource
  has_many :subject_resource_links, foreign_key: :subject_resource_id, class_name: :ResourceLink, inverse_of: :subject_resource, dependent: :destroy
  has_many :object_resource_links, foreign_key: :object_resource_id, class_name: :ResourceLink, inverse_of: :object_resource, dependent: :destroy
  has_many :assignments, inverse_of: :resource, dependent: :destroy
  has_many :meta, through: :representations

  has_many :resource_group_resources, inverse_of: :resource, dependent: :destroy
  has_many :resource_groups, ->(resource) { where(organization_id: resource.organization_id) }, through: :resource_group_resources, inverse_of: :resources
  has_many :resource_webhook_calls, dependent: :destroy

  has_one_attached :uploaded_resource

  scope :represented, -> { where.not(representations_count: 0) }
  scope :unrepresented, -> { where(representations_count: 0) }
  scope :assigned, -> { includes(:assignments).references(:assignments).where.not(assignments: {id: nil}) }
  scope :unassigned, -> { includes(:assignments).references(:assignments).where(assignments: {id: nil}) }
  scope :assigned_unrepresented, -> { unrepresented.joins(:assignments) }
  scope :unassigned_unrepresented, -> { unrepresented.left_outer_joins(:assignments).where(assignments: {resource_id: nil}) }
  scope :in_organization, ->(organization) { where(organization_id: organization) }
  scope :by_date, -> { order(created_at: :desc) }
  scope :by_priority, -> { order(priority_flag: :desc) }
  scope :by_priority_and_date, -> { by_priority.by_date }
  scope :represented_by, ->(user) { joins(:representations).where(representations: {author_id: user.id}) }
  scope :with_approved_representations, -> { joins(:representations).where(representations: {status: Coyote::Representation::STATUSES[:approved]}).distinct }

  validates :resource_type, presence: true
  validates :canonical_id, uniqueness: {scope: :organization_id}, allow_blank: true, if: :check_canonical_id?
  validates :source_uri, presence: true
  validates :source_uri, uniqueness: {case_sensitive: false, scope: :organization_id}, if: :check_source_uri?
  validates :name, presence: true

  enum resource_type: Coyote::Resource::TYPES

  audited

  paginates_per Rails.configuration.x.resource_api_page_size # see https://github.com/kaminari/kaminari#configuring-max-per_page-value-for-each-model-by-max_paginates_per
  # max_paginates_per Rails.configuration.x.resource_api_page_size # see https://github.com/kaminari/kaminari#configuring-max-per_page-value-for-each-model-by-max_paginates_per

  delegate :name, to: :resource_group, prefix: true

  def self.find_or_initialize_by_canonical_id_or_source_uri(options)
    canonical_id = options[:canonical_id]
    has_canonical_id = canonical_id.present?

    source_uri = options[:source_uri]
    has_source_uri = source_uri.present?
    return new if !has_source_uri && !has_canonical_id

    instance = if has_canonical_id
      find_or_initialize_by(canonical_id: canonical_id)
    else
      find_or_initialize_by(source_uri_hash: source_uri_hash_for(source_uri))
    end

    instance.skip_unique_validations = has_canonical_id ? :canonical_id : :source_uri
    instance
  end

  # @return [ActiveSupport::TimeWithZone] if one more resources exist, this is the created_at time for the most recently-created resource
  # @return [nil] if no resources exist
  def self.latest_timestamp
    order(:created_at).last.try(:created_at)
  end

  # @see https://github.com/activerecord-hackery/ransack#using-scopesclass-methods
  def self.ransackable_scopes(_ = nil)
    %i[
      represented
      assigned
      unassigned
      unrepresented
      assigned_unrepresented
      unassigned_unrepresented
      with_approved_representations
    ]
  end

  def self.source_uri_hash_for(source_uri)
    Digest::MD5.hexdigest(source_uri.to_s.downcase.strip.gsub(/\A(https?:)?\/\//, ""))
  end

  def self.without_webhooks
    previous_webhooks_setting = Thread.current[SKIP_WEBHOOKS_KEY]
    Thread.current[SKIP_WEBHOOKS_KEY] = true
    if block_given?
      yield
    else
      create_with(skip_webhooks: true)
    end
  ensure
    Thread.current[SKIP_WEBHOOKS_KEY] = previous_webhooks_setting
  end

  def approved?
    return @approved if defined? @approved
    @approved = complete? && representations.any? && representations.all?(&:approved?)
  end

  def assign_to_user_id=(new_user_id)
    return if new_user_id.blank?
    assignments.build(user: organization.users.find(new_user_id))
  end

  def assigned?
    !unassigned?
  end

  def assigned_to?(user)
    assignments.find_by(user_id: user.id)
  end

  def best_representation
    return @best_representation if defined? @best_representation
    @best_representation = representations.by_status_and_ordinality.pick(:text)
  end

  def complete?
    return @complete if defined? @complete
    required_ids = organization.meta.is_required.pluck("id")
    @complete = (representations.where.not(status: :not_approved).pluck("DISTINCT(metum_id)") & required_ids).size == required_ids.size
  end

  def content_changed?
    (previous_changes.keys & %w[name resource_type canonical_id source_uri priority_flag host_uris]).any?
  end

  # @param value [String] a newline-delimited list of host URIs to store for this Resource
  def host_uris=(value)
    @new_host_uris = value.is_a?(Array) ? value : value.to_s.split(/[\r\n]+/)
  end

  # @return [String] a human-friendly means of identifying this resource in names and select boxes
  def label
    @label ||= canonical_id.present? ? "#{name} (#{canonical_id})" : name
  end

  def mark_as_deleted!
    update_attribute(:is_deleted, true)
  end

  def new_representations
    @new_representations ||= []
  end

  def notify_webhook!
    return if skip_webhooks?
    NotifyWebhookWorker.perform_async(id) if resource_groups.has_webhook.any?
  end

  def partially_approved?
    complete? && !approved?
  end

  def partially_complete?
    return @partially_complete if defined? @partially_complete
    @partially_complete = represented? && !complete?
  end

  def progress
    return "Described" if approved?
    return "Pending" if partially_approved?
    return "Partially Completed" if partially_complete?
    "Undescribed"
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
    # Reset the latest set of representations we've received
    @new_representations = []

    # Iterate through the array of hashes and find_or_create representations for each
    representations_attributes.each do |attributes|
      attributes = attributes.with_indifferent_access

      # Find a metum for the representation, accepting a name or an ID
      metum_name = attributes.delete(:metum)
      metum_id = attributes.delete(:metum_id) || (metum_name.present? && organization.meta.where(name: metum_name).first_id)
      metum_id ||= organization.meta.where(name: "Alt").first_id

      # Don't add extra representations for this metum unless `overwrite_representations` is set
      next if !overwrite_representations && representations.approved.where(language: attributes[:language], metum_id: metum_id).any?

      # If there's a pre-existing representation this this metum, language and text, don't create a
      # new one - just update the old one
      representation = representations.find_or_initialize_by_text(attributes[:text], language: attributes[:language], metum_id: metum_id)
      if representation.new_record?
        # Set the author_id if it needs to be set
        attributes[:author_id] ||= organization.memberships.active.by_creation.first_id(:user_id)

        # Increase ordinality for new representations when there are other representations with this metum
        attributes[:ordinality] = representations.where.not(id: representation.id).with_metum(attributes[:metum_id]).count
        attributes[:status] ||= :approved
      end

      # Find a license for the representation, accepting a name or an ID
      license_name = attributes.delete(:license)
      license_id = attributes.delete(:license_id) || (license_name.present? && License.where(name: license_name).first_id)
      representation.license_id ||= license_id || organization.default_license_id || License.all.first_id

      # Assign whatever is left in the attributes
      representation.assign_attributes(attributes)
      new_representations.push(representation)
    end
  end

  def represented?
    !unrepresented?
  end

  def resource_group
    @resource_group ||= resource_groups.first
  end

  def resource_group_id=(resource_group_id)
    return if resource_group_id.blank?
    self.resource_group_ids = resource_group_ids + [resource_group_id.to_i] if resource_group_ids.exclude?(resource_group_id)
  end

  def resource_group_ids=(value)
    new_ids = value.is_a?(Array) ? value : value.to_s.split(/[\r\n]+/)
    @new_resource_group_ids = organization.resource_groups.where(id: new_ids).pluck(:id) # ensure we only attach resource groups for this org
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

  def check_canonical_id?
    Array(skip_unique_validations).include?(:canonical_id) && canonical_id_changed?
  end

  def check_source_uri?
    Array(skip_unique_validations).include?(:source_uri) && source_uri_changed?
  end

  def clear_blank_canonical_ids
    self.canonical_id = canonical_id.presence
  end

  def merge_host_uris
    return unless @new_host_uris
    self[:host_uris] = union_host_uris ? (host_uris || []).union(@new_host_uris) : @new_host_uris
  end

  def merge_resource_groups
    return unless @new_resource_group_ids
    self.resource_groups = organization.resource_groups.find(union_resource_groups ? (resource_group_ids || []).union(@new_resource_group_ids) : @new_resource_group_ids)
  end

  def set_default_resource_group
    resource_groups << organization.resource_groups.default.first unless resource_groups.any?
  end

  def set_source_uri_hash
    self.source_uri_hash = source_uri.present? ? self.class.source_uri_hash_for(source_uri) : nil
  end

  def skip_webhooks?
    skip_webhooks.present? || Thread.current[SKIP_WEBHOOKS_KEY].present?
  end
end
