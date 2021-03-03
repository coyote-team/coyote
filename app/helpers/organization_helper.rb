# frozen_string_literal: true

module OrganizationHelper
  def url_for_organization(organization)
    return request.url if current_organization? && current_organization == organization
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
