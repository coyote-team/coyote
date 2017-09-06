class UsersController < ApplicationController
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show edit update destroy]

  respond_to :html, :json

  helper_method :user, :users

  # GET /users
  def index
    self.users = current_organization.users.sorted
  end

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    if user.update(user_params)
      flash[:notice] = "#{user} was successfully updated."
      redirect_to [current_organization,user]
    else
      logger.warn "Unable to update #{user}: '#{user.errors.full_messages.to_sentence}'"
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    if user.destroy
      flash[:notice] = 'User was successfully destroyed.'
    else
      logger.warn "Unable to delete #{user}: '#{user.errors.full_messages.to_sentence}'"
    end

    redirect_to organization_users_url(current_organization)
  end

  private
  
  attr_accessor :user, :users

  def user
    self.user = current_organization.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name,:last_name,:email,:admin,:password,:password_confirmation,:role)
  end

  def authorize_general_access
    authorize User
  end

  def authorize_unit_access
    authorize(user)
  end
end
