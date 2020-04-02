# frozen_string_literal: true

module Staff
  # Allows staff to inititate password resets
  class UserPasswordResetsController < Staff::ApplicationController
    def create
      user = User.find(params.require(:user_id))
      user.send_reset_password_instructions
      msg = "Password reset emailed to #{user.email}"
      logger.info msg
      redirect_to staff_user_path(user), notice: msg
    end
  end
end
