# frozen_string_literal: true

module Staff
  # Staff-only CRUD functions for Users
  class UsersController < Staff::ApplicationController
    before_action :set_user, only: %i[show edit update destroy]

    helper_method :user, :users

    def destroy
      user.update_attribute(:active, false)
      msg = "Archived #{user}"
      redirect_to staff_users_path, notice: msg
    rescue ActiveRecord::DeleteRestrictionError => e
      msg = "Unable to archive '#{user}' due to '#{e}'"
      logger.error msg
      redirect_to staff_user_path(user), alert: msg
    end

    def edit
    end

    def index
      self.users = User.sorted
    end

    def show
    end

    def update
      if user.update(user_params)
        redirect_to staff_user_path(user), notice: "User was successfully updated"
      else
        logger.warn "Unable to update #{user}: #{user.error_sentence}"
        render :edit
      end
    end

    private

    attr_accessor :user, :users

    def set_user
      self.user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :staff)
    end
  end
end
