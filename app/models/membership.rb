# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE)
#  role            :enum             default("guest"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_memberships_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

# Represents a user belonging to one or more organizations
class Membership < ApplicationRecord
  after_create :update_user_counter_cache
  after_destroy :update_user_counter_cache

  belongs_to :user
  belongs_to :organization

  delegate :first_name, :last_name, :email, to: :user, allow_nil: true

  validates :role, presence: true

  enum role: Coyote::Membership::ROLES

  scope :active, -> { where(active: true) }
  def assignments
    user.assignments.joins(:resource).where(resources: {organization_id: organization_id})
  end

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
    user.update_organization_counter_cache
  end
end
