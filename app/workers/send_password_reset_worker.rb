# frozen_string_literal: true

class SendPasswordResetWorker < ApplicationWorker
  def perform(password_reset_id)
    password_reset = PasswordReset.find(password_reset_id)
    PasswordResetMailer.instructions(password_reset).deliver
  end
end
