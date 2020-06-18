# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  skip_before_action :require_user
  before_action :redirect_to_return_path, if: :current_user?

  before_action :find_password_reset, only: %i[show update]

  def create
    @user = User.find_by(email: password_reset_params[:email])
    if @user.present?
      PasswordReset.create!(user: @user)
      redirect_to sent_password_resets_path, notice: t("password_reset.sent")
    else
      flash[:error] = "A user with that email doesn't exist. Did you want to sign up instead?"
      render :new
    end
  end

  def new
  end

  def sent
  end

  def show
  end

  def update
    user = @password_reset.user
    if user.update(user_params)
      @password_reset.touch(:expires_at)
      log_user_in(user, notice: t("password_reset.updated"), remember: false)
    else
      flash[:error] = "Your password could not be reset"
      render :show
    end
  end

  private

  def find_password_reset
    @password_reset = PasswordReset.find_by!(token: params[:id])
    if @password_reset.expired?
      redirect_to new_password_reset_path, alert: "Sorry, this link has expired! Please try again."
    end
  end

  def password_reset_params
    (request.get? ? params.fetch(:user, {}) : params.require(:user)).permit(:email)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
