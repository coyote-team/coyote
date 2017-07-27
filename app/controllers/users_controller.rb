class UsersController < ApplicationController
  before_filter :admin
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json

  helper_method :user, :users

  # GET /users
  def index
    self.users = User.sorted
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    self.user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    self.user = User.new(user_params)
    flash[:notice] = "#{@user} was successfully created." if @user.save
    respond_with @user
  end

  # PATCH/PUT /users/1
  def update
    flash[:notice] = "#{user} was successfully updated." if user.update(user_params)
    respond_with user
  end

  # DELETE /users/1
  def destroy
    user.destroy
    flash[:notice] = 'User was successfully destroyed.'
    respond_with user
  end

  private
  
  attr_accessor :user, :users

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :admin, :password, :password_confirmation)
  end
end
