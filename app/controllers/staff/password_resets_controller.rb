# frozen_string_literal: true

module Staff
  # Allows staff to inititate password resets
  class PasswordResetsController < Staff::ApplicationController
    def create
      user = User.find(params.require(:user_id))
      PasswordReset.create!(user: user)
      msg = "Password reset emailed to #{user.email}"
      logger.info msg
      redirect_to staff_user_path(user), notice: msg
    end
  end
end
