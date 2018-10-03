module OrganizationScope
  private

  def organization_scope
    # can't do this in Pundit, since Pundit needs the results of this scoping
    if current_user.staff?
      Organization.all
    else
      Organization.joins(:memberships).where(memberships: { user: current_user })
    end
  end
end
