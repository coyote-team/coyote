class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  acts_as_token_authentication_handler_for User, if: lambda { |controller| controller.request.format.json? }

  analytical

  enable_authorization do |exception|
    redirect_to root_url, :alert => exception.message
  end unless :devise_controller?

  def search_params
    params[:q]
  end

  def clear_search_index
    if params[:search_cancel]
      params.delete(:search_cancel)
      if(!search_params.nil?)
        search_params.each do |key, param|
          search_params[key] = nil
        end
      end
    end
  end

  protected
  def admin
    redirect_to(root_url) unless current_user and current_user.admin?
  end

  def users
    redirect_to(root_url) if current_user.nil?
  end

  def prep_assign_to
    if current_user and current_user.admin?
      @users = User.all
    end
  end
end
