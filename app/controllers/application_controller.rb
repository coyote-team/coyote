class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  acts_as_token_authentication_handler_for User

  analytical 

  enable_authorization do |exception|
    redirect_to root_url, :alert => exception.message
  end unless :devise_controller?

  protected
    def admin
      redirect_to(root_url) unless current_user and current_user.admin?
    end

    def users
      redirect_to(root_url) if current_user.nil?
    end
end
