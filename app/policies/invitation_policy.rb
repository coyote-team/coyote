# Protects Invitation objects
# @see Invitation
class InvitationPolicy < ApplicationPolicy
  # @return [Boolean] Organization admins and owners can always invite new users
  def new?
    organization_user.admin?
  end

  # Organization owners can always invite new users of any role. Admin users can invite new users of any rank below admin
  # @return [Boolean] whether or not the user can create an invitation like this one
  def create?
    return true if organization_user.owner?
    organization_user.admin? && record.role_rank < organization_user.role_rank
  end
end
