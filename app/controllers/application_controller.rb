# frozen_string_literal: true

# @abstract Base class for all Coyote controllers
class ApplicationController < ActionController::Base
  include OrganizationScope
  include Pundit

  protect_from_forgery with: :exception

  before_action :require_user

  before_action :configure_sentry if defined? Raven

  analytical

  helper_method :body_class,
    :current_organization,
    :current_organization?,
    :current_user,
    :current_user?,
    :filter_params,
    :organization_scope,
    :organization_user,
    :pagination_link_params,
    :return_to_path

  if Rails.env.production?
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from Pundit::NotAuthorizedError, with: :unauthorized
  end

  private

  def auth_token
    return @auth_token if defined? @auth_token
    @auth_token = session[AuthToken::KEY] || cookies.signed[AuthToken::KEY]
  end

  def bad_request
    render "application/bad_request", status: :bad_request
  end

  def body_class(class_name = nil)
    @body_class ||= [
      controller_name,
      action_name,
      [controller_name, action_name].join("-"),
    ]
    @body_class.push(class_name) if class_name.present?
    @body_class.join(" ")
  end

  # :nocov:
  def configure_sentry
    Raven.user_context(id: current_user&.id, username: current_user.username, name: current_user.name) if user_signed_in?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def current_organization
    return @current_organization if defined? @current_organization
    @current_organization = organization_scope.find(params[:organization_id])
  end

  def current_organization?
    current_user.present? && organization_scope.exists?(params[:organization_id])
  end

  def current_user
    return @current_user if defined? @current_user
    @current_user = auth_token.presence && User.joins(:auth_tokens).find_by(auth_tokens: {token: auth_token})
  end

  def current_user?
    current_user.present?
  end

  # :nocov:

  def log_user_in(user, options = {})
    remember = options.delete(:remember)
    auth_token = user.auth_tokens.create!(user_agent: request.user_agent)
    token = auth_token.token
    user.update(
      current_sign_in_at: Time.zone.now,
      current_sign_in_ip: request.ip,
      last_sign_in_at:    user.current_sign_in_at,
      last_sign_in_ip:    user.current_sign_in_ip,
    )

    if remember
      cookie = {
        httponly: true,
        expires:  1.month.from_now,
        value:    token,
      }
      cookies.signed[AuthToken::KEY] = cookie
    else
      session[AuthToken::KEY] = token
    end

    redirect_to_return_path(user, options)
  end

  def not_found
    render "application/not_found", status: :not_found
  end

  def organization_user
    @organization_user ||= Coyote::OrganizationUser.new(current_user, current_organization)
  end

  alias pundit_user organization_user

  def redirect_to_return_path(*args)
    options = args.extract_options!
    user = args.shift || current_user
    path = options.delete(:path) || return_to_path
    organization = return_to_path.blank? && user.organizations.limit(1).pluck(:id).first
    path ||= organization.present? ? organization_path(organization) : root_path
    redirect_to path, options
  end

  def require_user
    redirect_to new_session_path(Session::RETURN_TO_KEY => request.path) unless current_user?
  end

  def return_to_path
    params[Session::RETURN_TO_KEY]
  end

  def unauthorized
    render "application/authorized", status: :unauthorized
  end
end
