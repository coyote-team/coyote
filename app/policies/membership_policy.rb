# frozen_string_literal: true

# Protects Membership objects
class MembershipPolicy < ApplicationPolicy
  # @return [false] Memberships can only be created via Invitation
  # @see Invitation
  # @see InvitationPolicy
  def create?
    false
  end

  alias_method :new?, :create?

  # @return [Boolean] if attempting to destroy one's own membership, or if the user is an admin and is not attempting to destroy another admin's membership
  def destroy?
    return true if organization_user.owner?
    return true if self?
    return false if same_rank_or_lower?
    organization_user.admin?
  end

  # @return [Boolean] only editors or above can view an organization's memberships
  def index?
    organization_user.editor?
  end

  alias_method :show?, :index?

  # @return [true] if the user is an admin and is not editing his/her own membership
  # @return [false] if the user is not an admin, or is an admin who is trying to edit his/her own membership
  def update?
    return true if organization_user.owner?
    return false if self?
    return false if same_rank_or_lower?
    organization_user.admin?
  end

  alias_method :edit?, :update?

  private

  def same_rank_or_lower?
    organization_user.role_rank <= record.role_rank
  end

  def self?
    record.user_id == organization_user.id
  end
end
