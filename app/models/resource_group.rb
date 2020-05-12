# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_groups
#
#  id              :integer          not null, primary key
#  default         :boolean          default(FALSE)
#  name            :string           not null
#  webhook_uri     :string
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_name  (organization_id,name) UNIQUE
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

  before_destroy :check_for_resources_or_default

  validates :name, presence: true
  validates :name, uniqueness: {scope: :organization_id}
  validates :default, uniqueness: {if: :default?, scope: :organization_id}
  validate :webhook_uri_is_valid?, if: :webhook_uri?

  has_many :resource_group_resources, inverse_of: :resource_group
  has_many :resources, through: :resource_group_resources, inverse_of: :resource_groups

  belongs_to :organization, inverse_of: :resource_groups

  scope :by_default_and_name, -> { order({default: :desc}, {name: :asc}) }
  scope :default, -> { where(default: true) }
  scope :has_webhook, -> { where.not(webhook_uri: nil) }

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

  def webhook_uri_is_valid?
    return true if URI::DEFAULT_PARSER.make_regexp(%w[http https]).match?(webhook_uri) && URI.parse(webhook_uri).host.present?
    raise URI::InvalidURIError
  rescue URI::InvalidURIError
    errors.add(:webhook_uri, "is not a valid URL")
  end
end
