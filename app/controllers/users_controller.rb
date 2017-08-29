class UsersController < ApplicationController
  before_action :authorize_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json

  helper_method :user, :users

  # GET /users
  def index
    self.users = current_organization.users.sorted
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    self.user = current_organization.users.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    self.user = User.new(user_params)

    if user.save
      current_organization.users << user
      logger.info "Created user '#{user}'"
      flash[:notice] = "#{user} was successfully added to #{current_organization}." 
      redirect_to [current_organization,user]
    else
      logger.warn "Unable to create User: '#{user.errors.full_messages.to_sentence}'"
      render :new
    end
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

    redirect_to [current_organization,user]
  end

  private
  
  attr_accessor :user, :users

  def set_user
    self.user = current_organization.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name,:last_name,:email,:admin,:password,:password_confirmation,:role)
  end
end
