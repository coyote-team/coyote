# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                 :integer          not null, primary key
#  is_deleted         :boolean          default(FALSE)
#  name               :citext           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  default_license_id :integer          not null
#
# Indexes
#
#  index_organizations_on_is_deleted  (is_deleted)
#  index_organizations_on_name        (name) UNIQUE
#

# Represents a group of users, usually associated with a particular institution
class Organization < ApplicationRecord
  after_create :create_default_meta
  after_create :create_default_resource_group

  validates :name, presence: true
  validates :name, uniqueness: true, if: :name_changed?

  belongs_to :default_license, class_name: "License"

  has_many :memberships, inverse_of: :organization, dependent: :destroy
  has_many :users, through: :memberships
  has_many :active_users, -> { where(memberships: {active: true}) }, source: :user, through: :memberships
  has_many :resources, dependent: :restrict_with_exception, inverse_of: :organization
  has_many :resource_groups, inverse_of: :organization, dependent: :destroy
  has_many :meta, inverse_of: :organization, dependent: :destroy
  has_many :assignments, through: :resources
  has_many :representations, through: :resources

  has_many :unassigned_unrepresented_resources, -> { unassigned_unrepresented }, class_name: :Resource, inverse_of: :organization

  scope :is_active, -> { where(is_deleted: false) }

  def ready_to_review_representations
    representations.ready_to_review
  end

  private

  def create_default_meta
    Metum::DEFAULTS.each do |attributes|
      meta.find_or_create_by(name: attributes[:name]) do |metum|
        metum.instructions = attributes[:instructions]
        metum.is_required = true
      end
    end
  end

  def create_default_resource_group
    resource_groups.find_or_create_by(default: true, name: ResourceGroup::DEFAULT_NAME)
  end
end
