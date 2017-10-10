# rubocop:disable Style/ClassAndModuleChildren necessary to flatten namespace here because of how Rails autoloading works

# @abstract Base class for all API controllers
# @see http://api.rubyonrails.org/classes/ActionController/API.html
class Api::ApplicationController < ActionController::API
  before_action :require_api_authentication

  private

  attr_accessor :current_user
  
  def require_api_authentication
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    self.current_user = User.find_for_authentication(authentication_token: request.authorization)
  end

  def render_unauthorized
    render :jsonapi_errors => [{ 
      title: 'Invalid Authorization Token',
      detail: 'You must provide a valid API authorization token in the HTTP_AUTHORIZATION header'
    }], :status => :unauthorized
  end
end

# rubocop:enable Style/ClassAndModuleChildren
