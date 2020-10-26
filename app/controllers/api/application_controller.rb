# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren necessary to flatten namespace here because of how Rails autoloading works

# @abstract Base class for all API controllers
# @see http://api.rubyonrails.org/classes/ActionController/API.html
class Api::ApplicationController < ActionController::API
  extend ApipieJSONAPI
  include OrganizationScope
  include Pundit
  include TrapErrors

  before_action :require_api_authentication
  around_action :skip_webhooks

  def_param_group :pagination do
    param :page, Hash, "Optional pagination settings", required: false do
      param :number, Integer, "Identifies the page of results to retrieve, numbered starting at 1"
      param :size, Integer, "How many records to return per page"
    end
  end

  def self.representation_params_builder
    -> {
      param :text, String, "The text of the representation", required: true
      param :language, String, "The language code for this representation", required: true
      param :author_id, Integer, "The user who authored this representation's ID - defaults to the user making the API request", required: false
      param :license, String, "The name of the license which applies to this represenation", required: false
      param :license_id, Integer, "The ID of the license which applies to this represenation", required: false
      param :metum, String, "The name of the metum which this represenation uses", required: false
      param :metum_id, Integer, "The ID of the metum which this represenation uses", required: false
      param :status, Coyote::Representation::STATUSES.keys, "The status of the representation. New representations default to `ready_to_review`."
    }
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
    scope = current_user.staff? ? Resource : current_user.resources
    self.resource = params[:canonical_id].present? ?
      scope.find_by!(canonical_id: params[:canonical_id]) :
      scope.find(params[:resource_id] || params[:id])
    self.current_organization = params[:organization_id] ? current_organization : resource.organization
  end

  def organization_user
    @organization_user ||= Coyote::OrganizationUser.new(current_user, current_organization)
  end

  alias_method :pundit_user, :organization_user

  def render_unauthorized
    render jsonapi_errors: [{
      title:  "Invalid Authorization Token",
      detail: "You must provide a valid API authorization token in the HTTP_AUTHORIZATION header",
    }], status: :unauthorized
  end

  def require_api_authentication
    authenticate_token || render_unauthorized
  end

  def skip_webhooks
    Resource.without_webhooks do
      yield
    end
  end

  def trap_forbidden(_)
    render json: {error: "Forbidden"}, status: :forbidden
  end

  def trap_not_found(_)
    render json: {error: "Not found"}, status: :not_found
  end

  def trap_unprocessable_entity(exception)
    render json: {error: I18n.t("actioncontroller.parameter_missing", param: exception.param)}, status: :unprocessable_entity
  end
end

# rubocop:enable Style/ClassAndModuleChildren
