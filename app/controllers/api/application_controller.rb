# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren necessary to flatten namespace here because of how Rails autoloading works

# @abstract Base class for all API controllers
# @see http://api.rubyonrails.org/classes/ActionController/API.html
class Api::ApplicationController < ActionController::API
  include OrganizationScope
  include Pundit

  before_action :require_api_authentication

  def_param_group :pagination do
    param :'page[number]', Integer, "Identifies the page of results to retrieve, numbered starting at 1"
    param :'page[size]', Integer, "How many records to return per page"
  end

  private

  attr_accessor :current_user
  attr_writer :current_organization

  def authenticate_token
    self.current_user = User.find_for_authentication(authentication_token: request.authorization)
  end

  def current_organization
    @current_organization ||= organization_scope.find(params[:organization_id])
  end

  def find_resource
    id = params[:resource_identifier] || params[:id]
    self.resource = current_user.resources.where(canonical_id: id).or(
      current_user.resources.where(identifier: id),
    ).first!
    self.current_organization = params[:organization_id] ? current_organization : resource.organization
  end

  def organization_user
    @organization_user ||= Coyote::OrganizationUser.new(current_user, current_organization)
  end

  alias pundit_user organization_user

  def render_unauthorized
    render jsonapi_errors: [{
      title:  "Invalid Authorization Token",
      detail: "You must provide a valid API authorization token in the HTTP_AUTHORIZATION header",
    }], status: :unauthorized
  end

  def require_api_authentication
    authenticate_token || render_unauthorized
  end
end

# rubocop:enable Style/ClassAndModuleChildren
