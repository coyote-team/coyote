# @abstract Base class for all Coyote controllers
class ApplicationController < ActionController::Base
  include Pundit
  
  helper_method :current_organization, :current_organization?, :organization_user

  protect_from_forgery :with => :exception

  before_action :authenticate_user!

  skip_before_action :authenticate_user!, if: ->(controller) { controller.instance_of?(HighVoltage::PagesController) }

  before_action :configure_permitted_parameters, :if => :devise_controller?
  
  analytical

  protected

  attr_accessor :users, :contexts

  def organization_user
    @organization_user ||= Coyote::OrganizationUser.new(current_user,current_organization)
  end

  alias pundit_user organization_user

  def get_contexts
    self.contexts = Context.all.sort { |a,b| a.to_s <=> b.to_s } # TODO: needs to be moved into Context scope, sorted via SQL
  end

  def after_sign_in_path_for(user)
    if user.organizations.one?
      organization_path(user.organizations.first)
    else
      organizations_path
    end
  end

  def current_organization?
    current_user.organizations.exists?(current_organization_id)
  end

  def current_organization
    @current_organization ||= current_user.organizations.find(current_organization_id)
  end

  def current_organization_id
    params[:organization_id] # intended to be overridden in the OrganizationController
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update,keys: %i[first_name last_name])
  end
end
