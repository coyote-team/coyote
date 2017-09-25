# Protects Membership objects
class MembershipPolicy < ApplicationPolicy
  # @return [Boolean] all users can view an organization's memberships
  def index?
    true
  end

  alias show? index?

  # @return [false] Memberships can only be created via Invitation
  # @see Invitation
  # @see InvitationPolicy
  def create?
    false
  end

  alias new? create?

  # @return [true] if the user is an admin and is not editing his/her own membership
  # @return [false] if the user is not an admin, or is an admin who is trying to edit his/her own membership
  def update?
    return true if organization_user.staff?
    return false if self?
    return false if same_rank_or_lower?
    organization_user.admin?
  end

  alias edit? update?

  # @return [Boolean] if attempting to destroy one's own membership, or if the user is an admin and is not attempting to destroy another admin's membership
  def destroy?
    return true if organization_user.staff?
    return true if self? 
    return false if same_rank_or_lower?
    organization_user.admin?
  end

  private

  def self?
    record.user_id == organization_user.id
  end

  def same_rank_or_lower?
    organization_user.role_rank <= record.role_rank
  end
end
