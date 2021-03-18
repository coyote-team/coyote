# frozen_string_literal: true

module OrganizationHelper
  def best_root_path
    return root_path if stateless?
    return organization_path(current_organization) if current_organization?
    return root_path unless current_user?

    if organization_scope.many?
      organizations_path
    elsif organization_scope.one?
      organization_path(organization_scope.first)
    else
      root_path
    end
  end

  def url_for_organization(organization)
    return request.url if current_organization? && current_organization == organization
    return organization_path(organization) if organization_controller? && action_name == "index"
    return url_for(organization_id_param => organization) if organization_controller? || params[:id].blank?
    begin
      # Try to route to the root of the current context
      url_for(action: :index)
    rescue
      # Fallback to the organization dashboard
      organization_path(organization)
    end
  end
end
