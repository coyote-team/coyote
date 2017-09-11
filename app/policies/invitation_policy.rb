# Protects Invitation objects
# @see Invitation
class InvitationPolicy < ApplicationPolicy
  # Organization owners can always invite new users of any role. Admin users can invite new users of any rank below admin
  # @return [Boolean] whether or not the user can invite other users to the organization
  def create?
    return true if organization_user.owner?
    organization_user.admin? && record.role_rank < organization_user.role_rank
  end

  alias new? create?
end
