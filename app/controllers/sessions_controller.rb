# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_user
  before_action :redirect_to_return_path, except: %i[destroy], if: :current_user?

  def create
    session = Session.new(session_params)

    case user = session.authenticate!
    when User
      # Set user session cookies and whatnots
      return log_user_in(user, notice: t("session.signed_in"), remember: session_params[:remember_me])
    when Session::INCORRECT_PASSWORD
      # Bad password
      flash[:error] = t("session.invalid")
    when Session::NO_USER
      # No user with that email
      flash[:error] = t("session.not_found_in_database")
    end

    @user = User.new(session_params.except(:password))
    render :new
  end

  def destroy
    cookies.delete(AuthToken::KEY)
    session.delete(AuthToken::KEY)
    redirect_to root_path, notice: t("session.signed_out")
  end

  def new
    @user = User.new(session_params)
  end

  private

  def session_params
    (request.get? ? params.fetch(:user, {}) : params.require(:user)).permit(:email, :password, :remember_me)
  end
end
