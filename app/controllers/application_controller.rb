# frozen_string_literal: true

# @abstract Base class for all Coyote controllers
class ApplicationController < ActionController::Base
  include OrganizationScope
  include Pundit

  protect_from_forgery with: :exception

  before_action :store_user_location!, if: :storable_location? # see https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :configure_sentry if defined? Raven

  analytical

  helper_method :current_organization, :current_organization?, :organization_scope, :organization_user, :pagination_link_params, :filter_params

  protected

  def after_sign_in_path_for(user)
    stored_path = stored_location_for(:user)

    if stored_path.present? && stored_path != root_path
      stored_path
    elsif user.organizations.one?
      organization_path(user.organizations.first)
    else
      organizations_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
  end

  def current_organization
    @current_organization ||= organization_scope.find(params[:organization_id])
  end

  def current_organization?
    current_user.present? && organization_scope.exists?(params[:organization_id])
  end

  def organization_user
    @organization_user ||= Coyote::OrganizationUser.new(current_user, current_organization)
  end

  alias pundit_user organization_user

  private

  # :nocov:
  def configure_sentry
    Raven.user_context(id: current_user&.id, username: current_user.username, name: current_user.name) if user_signed_in?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
  # :nocov:

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
