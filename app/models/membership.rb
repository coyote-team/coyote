# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id              :bigint(8)        not null, primary key
#  user_id         :bigint(8)        not null
#  organization_id :bigint(8)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role            :enum             default("guest"), not null
#  active          :boolean          default(TRUE)
#
# Indexes
#
#  index_memberships_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#

# Represents a user belonging to one or more organizations
class Membership < ApplicationRecord
  after_create :update_user_counter_cache
  after_destroy :update_user_counter_cache

  belongs_to :user
  belongs_to :organization

  validates :role, presence: true

  enum role: Coyote::Membership::ROLES

  delegate :assignments, to: :user, prefix: true

  scope :active, -> { where(active: true) }

  # @return [Boolean] whether this membership represents the last owner of an organization
  def last_owner?
    owner? && Membership.where(organization: organization).owner.one?
  end

  # @return (see Coyote::Membership#role_rank)
  def role_rank
    Coyote::Membership.role_rank(role)
  end

  private

  def update_user_counter_cache
    user.update_attribute(:organizations_count, user.organizations.count(true))
  end
end
