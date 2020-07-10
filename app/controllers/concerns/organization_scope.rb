# frozen_string_literal: true

module OrganizationScope
  private

  def organization_scope
    # can't do this in Pundit, since Pundit needs the results of this scoping
    if current_user.staff?
      Organization.is_active
    else
      Organization.is_active.joins(:memberships).where(memberships: {user: current_user})
    end
  end
end
