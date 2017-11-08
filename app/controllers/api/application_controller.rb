# rubocop:disable Style/ClassAndModuleChildren necessary to flatten namespace here because of how Rails autoloading works

# @abstract Base class for all API controllers
# @see http://api.rubyonrails.org/classes/ActionController/API.html
class Api::ApplicationController < ActionController::API
  include Pundit

  before_action :require_api_authentication

  def_param_group :pagination do
    param :'page[number]', Integer
    param :'page[size]', Integer, desc: 'How many records to return per page'
  end

  private

  attr_accessor :current_user
  
  def require_api_authentication
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    self.current_user = User.find_for_authentication(authentication_token: request.authorization)
  end

  def current_organization
    @current_organization ||= current_user.organizations.find(params[:organization_id])
  end

  def organization_user
    @organization_user ||= Coyote::OrganizationUser.new(current_user,current_organization)
  end

  alias pundit_user organization_user
  
  def render_unauthorized
    render :jsonapi_errors => [{ 
      title: 'Invalid Authorization Token',
      detail: 'You must provide a valid API authorization token in the HTTP_AUTHORIZATION header'
    }], :status => :unauthorized
  end

  def pagination_params
    params.fetch(:page,{}).permit(:number,:size)
  end
end

# rubocop:enable Style/ClassAndModuleChildren
