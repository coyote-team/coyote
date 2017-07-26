class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new {|c| c.request.format.json? }

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
    redirect_to(root_url) unless current_user.try(:admin?)
  end

  def users
    redirect_to(root_url) unless current_user
  end

  def get_users
    @users = User.sorted
  end

  def get_groups
    @groups = Group.all.sort { |a,b| a.to_s <=> b.to_s } 
  end
end
