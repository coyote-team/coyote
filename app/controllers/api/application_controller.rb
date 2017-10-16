# rubocop:disable Style/ClassAndModuleChildren necessary to flatten namespace here because of how Rails autoloading works

# @abstract Base class for all API controllers
# @see http://api.rubyonrails.org/classes/ActionController/API.html
class Api::ApplicationController < ActionController::API
  include Pundit

  before_action :require_api_authentication

  # see https://github.com/elabs/pundit#ensuring-policies-and-scopes-are-used
  after_action :verify_authorized, except: %i[index]

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
    current_user.organizations.find(params[:organization_id])
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

  def pagination_number
    pagination_params[:number]
  end

  def pagination_size
    pagination_params[:size]
  end

  def first_page_params
    # Kaminari numbers pages from 1 instead of 0
    pagination_params.merge(number: 1)
  end

  def pagination_link_params(records)
    links = { 
      first: pagination_params.merge(number: 1)
    }

    unless records.first_page?
      links[:prev] = pagination_params.merge(number: records.prev_page)
    end

    unless records.last_page?
      links[:next] = pagination_params.merge(number: records.next_page)
    end

    links
  end
  
  def apply_link_headers(links)
    link_headers = links.inject([]) do |result,(rel,href)|
      result << %(<#{href}>; rel="#{rel}")
    end

    headers['Link'] = link_headers.join(', ')
  end
end

# rubocop:enable Style/ClassAndModuleChildren
