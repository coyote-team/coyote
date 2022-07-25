# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                               :integer          not null, primary key
#  allow_authors_to_claim_resources :boolean          default(FALSE), not null
#  footer                           :string
#  is_deleted                       :boolean          default(FALSE)
#  name                             :citext           not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  default_license_id               :integer          not null
#
# Indexes
#
#  index_organizations_on_is_deleted  (is_deleted)
#  index_organizations_on_name        (name) UNIQUE WHERE (is_deleted IS FALSE)
#
# Foreign Keys
#
#  fk_rails_...  (default_license_id => licenses.id)
#

# Represents a group of users, usually associated with a particular institution
class Organization < ApplicationRecord
  attr_accessor :name_confirmation

  after_create :create_default_meta
  after_create :create_default_resource_group

  validates :name, presence: true
  validates :name, uniqueness: {conditions: -> { where.not(is_deleted: true) }}, if: :name_changed?
  validates :name, confirmation: {if: -> { name_confirmation.present? }}

  belongs_to :default_license, class_name: "License"

  has_many :imports, dependent: :destroy

  has_many :memberships, inverse_of: :organization, dependent: :destroy
  has_many :active_users, -> { active.where(memberships: {active: true}) }, source: :user, through: :memberships
  has_many :users, through: :memberships

  has_many :resources, dependent: :restrict_with_exception, inverse_of: :organization
  has_many :assignments, through: :resources
  has_many :representations, through: :resources
  has_many :unassigned_unrepresented_resources, -> { unassigned_unrepresented }, class_name: :Resource, inverse_of: :organization

  has_many :meta, inverse_of: :organization, dependent: :destroy
  has_many :resource_groups, inverse_of: :organization, dependent: :destroy

  has_one_attached :logo

  scope :is_active, -> { where(is_deleted: false) }

  # :nocov:
  def hard_delete
    original_auditing_enabled = Audited.auditing_enabled
    Audited.auditing_enabled = false
    Organization.transaction do
      # Delete deep metadata
      Assignment.joins(:resource).where(resources: {organization_id: id}).delete_all
      Representation.joins(:resource).where(resources: {organization_id: id}).delete_all
      ResourceGroupResource.joins(:resource).where(resources: {organization_id: id}).delete_all
      ResourceLink.joins(:subject_resource).where(resources: {organization_id: id}).delete_all
      ResourceLink.joins(:object_resource).where(resources: {organization_id: id}).delete_all
      ResourceWebhookCall.joins(:resource).where(resources: {organization_id: id}).delete_all

      # Delete direct children
      imports.delete_all
      memberships.delete_all
      meta.delete_all
      resource_groups.delete_all
      Resource.where(organization_id: id).delete_all
      destroy!
    end
  ensure
    Audited.auditing_enabled = original_auditing_enabled
  end
  # :nocov:

  def ready_to_review_representations
    representations.ready_to_review
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  private

  def create_default_meta
    Metum::DEFAULTS.each do |attributes|
      meta.find_or_create_by(name: attributes[:name]) do |metum|
        metum.assign_attributes(attributes)
      end
    end
  end

  def create_default_resource_group
    resource_groups.find_or_create_by(default: true, name: ResourceGroup::DEFAULT_NAME)
  end
end
