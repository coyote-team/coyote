# frozen_string_literal: true

# @abstract Base class for all Coyote controllers
class ApplicationController < ActionController::Base
  include OrganizationScope
  include Pundit
  include TrapErrors

  protect_from_forgery with: :exception
  prepend_view_path "app/assets/html"

  before_action :require_user

  before_action :configure_sentry if defined? Raven

  analytical

  helper_method :body_class,
    :current_organization,
    :current_organization?,
    :current_user,
    :current_user?,
    :filter_params,
    :mark_as_stateless!,
    :organization_scope,
    :organization_user,
    :pagination_link_params,
    :return_to_path,
    :stateless?

  def url_options
    result = super
    # return result if organization_controller?
    if organization_id.present?
      result.merge(organization_id: organization_id)
    elsif current_organization?
      result.merge(organization_id: current_organization)
    else
      result
    end
  end

  private

  def auth_token
    return @auth_token if defined? @auth_token
    @auth_token = session[AuthToken::KEY] || begin
      cookies.signed[AuthToken::KEY]
    rescue NoMethodError => error
      raise error unless /undefined method `generate_key'/.match?(error.message)
      nil
    end
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
    Raven.user_context(id: current_user&.id, username: current_user.username, name: current_user.name) if current_user?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
  # :nocov:

  def current_organization
    return @current_organization if defined? @current_organization
    @current_organization = organization_scope.find(params[:organization_id])
  end

  def current_organization?
    return @has_current_organization if defined? @has_current_organization
    @has_current_organization = current_user.present? && organization_scope.exists?(params[:organization_id])
  end

  def current_user
    return @current_user if defined? @current_user
    @current_user = auth_token.presence && User.joins(:auth_tokens).find_by(auth_tokens: {token: auth_token})
  end

  def current_user?
    current_user.present?
  end

  def default_landing_path(user = current_user)
    !user.staff? && user.organizations.one? ? organization_path(user.organizations.first) : organizations_path
  end

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

  def mark_as_stateless!
    body_class "stateless"
    @stateless = true
  end

  def organization_controller?
    controller_name == "organizations"
  end
  helper_method :organization_controller?

  def organization_id
    return @organization_id if defined? @organization_id
    @organization_id = params[organization_id_param] || params[:organization_id]
  end

  def organization_id_param
    organization_controller? ? :id : :organization_id
  end
  helper_method :organization_id_param

  def organization_user
    @organization_user ||= Coyote::OrganizationUser.new(current_user, current_organization)
  end

  alias_method :pundit_user, :organization_user

  def redirect_to_return_path(*args)
    options = args.extract_options!
    user = args.shift || current_user
    path = options.delete(:path) || return_to_path || default_landing_path(user)
    redirect_to path, options
  end

  def render_error(status)
    mark_as_stateless!
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] || 500
    render template: code.to_s, status: status
  end

  def require_user
    redirect_to new_session_path(Session::RETURN_TO_KEY => request.path) unless current_user?
  end

  def return_to_path
    params[Session::RETURN_TO_KEY]
  end

  def stateless?
    @stateless ||= false
  end

  def trap_forbidden(_)
    render_error :forbidden
  end

  def trap_not_found(_)
    render_error :not_found
  end

  def trap_unprocessable_entity(_)
    render_error :unprocessable_entity
  end
end
