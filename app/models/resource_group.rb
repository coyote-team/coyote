# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_groups
#
#  id                   :integer          not null, primary key
#  auto_match_host_uris :string           default([]), not null, is an Array
#  default              :boolean          default(FALSE)
#  name                 :citext           not null
#  token                :string
#  webhook_uri          :citext
#  created_at           :datetime
#  updated_at           :datetime
#  organization_id      :integer          not null
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_name  (organization_id,name) UNIQUE
#  index_resource_groups_on_webhook_uri               (webhook_uri)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => cascade ON UPDATE => cascade
#

# Represents the situation in which a subject is being considered. Determines what strategy we use to present a description of a subject.
# Examples of resource_groups include Web, Exhibitions, Poetry, Digital Interactive, Mobile, Audio Tour
# @see https://github.com/coyote-team/coyote/issues/112
class ResourceGroup < ApplicationRecord
  DEFAULT_NAME = "Uncategorized"

  before_save :set_token, if: :webhook_uri?
  before_destroy :check_for_resources_or_default
  after_save_commit :schedule_match, if: -> { previous_changes.key?(:auto_match_host_uris) }

  validates :name, presence: true
  validates :name, uniqueness: {case_sensitive: false, scope: :organization_id}, if: :name_changed?
  validates :default, uniqueness: {if: :default?, scope: :organization_id}, if: :default_changed?
  validate :webhook_uri_is_valid?, if: :webhook_uri?

  has_many :resource_group_resources, inverse_of: :resource_group, dependent: :destroy
  has_many :resources, through: :resource_group_resources, inverse_of: :resource_groups

  belongs_to :organization, inverse_of: :resource_groups

  scope :by_default_and_name, -> { order({default: :desc}, {name: :asc}) }
  scope :default, -> { where(default: true) }
  scope :has_webhook, -> { where.not(webhook_uri: nil) }

  def auto_match_host_uris=(value)
    super value.is_a?(Array) ? value : value.to_s.strip.split(/[\r\n]+/)
  end

  def match_resources!
    # Clean the URIs to schema-less regex fields
    match_uris = Array(auto_match_host_uris).each_with_object([]) do |match_uri, matches|
      match_uri.to_s.strip
      next if match_uri.blank?

      match_regex = '\A(https?:)?//' + match_uri.gsub(/\A(https?:)?\/\//, "")
      matches.push(match_regex)
    end

    # Find resources with matching host URIs using a regex query - this is not performant, so do
    # this in a worker
    resource_ids = organization.resources
      .distinct
      .from("#{Resource.table_name}, UNNEST(#{Resource.table_name}.host_uris) host_uri")
      .where("host_uri ~* ANY(ARRAY[?])", match_uris)
      .pluck(:id)

    # Upsert any matching resources, marking the new ones as 'is_auto_matched' TRUE. This will
    # allow us to clear them later.
    if resource_ids.any?
      insert_values = resource_ids.map { |resource_id| self.class.sanitize_sql_array(["(?, ?, TRUE, NOW(), NOW())", resource_id, id]) }.join("\n,")
      insert_query = "INSERT INTO #{ResourceGroupResource.table_name} (resource_id, resource_group_id, is_auto_matched, created_at, updated_at) VALUES #{insert_values}"
      insert_query = "#{insert_query} ON CONFLICT (resource_id, resource_group_id) DO NOTHING"
      self.class.connection.execute(insert_query)
    end

    # Delete all leftover auto-matched resources that *no longer match*
    resource_group_resources
      .where(is_auto_matched: true)
      .where.not(resource_id: resource_ids)
      .delete_all
  end

  def name_with_default_annotation
    "#{self}#{default ? " (default)" : ""}"
  end

  private

  def check_for_resources_or_default
    if default? || resources.any?
      errors.add(:base, default? ? "The default resource group cannot be deleted" : "It has resources in it")
      throw(:abort)
    end
  end

  def schedule_match
    MatchResourcesToResourceGroupWorker.perform_async(id)
  end

  def set_token
    self.token ||= SecureRandom.hex(16)
  end

  def webhook_uri_is_valid?
    return true if URI::DEFAULT_PARSER.make_regexp(%w[http https]).match?(webhook_uri) && URI.parse(webhook_uri).host.present?
    raise URI::InvalidURIError
  rescue URI::InvalidURIError
    errors.add(:webhook_uri, "is not a valid URL")
  end
end
