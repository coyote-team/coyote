# frozen_string_literal: true

# Protects Invitation objects
# @see Invitation
class InvitationPolicy < ApplicationPolicy
  # Organization owners can always invite new users of any role. Admin users can invite new users of any rank below admin
  # @return [Boolean] whether or not the user can create an invitation like this one
  def create?
    return true if organization_user.owner?
    organization_user.admin? && instance.role_rank <= organization_user.role_rank
  end

  # @return [Boolean] Organization admins and owners can always invite new users
  def new?
    organization_user.admin?
  end
end
