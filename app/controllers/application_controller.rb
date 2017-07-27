class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception
  protect_from_forgery :with => :null_session, if: ->(c) { c.request.format.json? }

  acts_as_token_authentication_handler_for User, if: lambda { |controller| controller.request.format.json? }

  analytical

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

  attr_accessor :users, :contexts

  def check_authorization
    redirect_to(root_url) unless current_user.try(:admin?)
  end

  def get_users
    self.users = User.sorted
  end

  def get_contexts
    self.contexts = Context.all.sort { |a,b| a.to_s <=> b.to_s } # TODO needs to be moved into Context scope, sorted via SQL
  end
end
