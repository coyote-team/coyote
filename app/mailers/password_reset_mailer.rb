# frozen_string_literal: true

class PasswordResetMailer < ApplicationMailer
  attr_accessor :password_reset, :url, :user
  helper_method :password_reset, :url, :user

  def instructions(password_reset)
    self.password_reset = password_reset
    self.url = password_reset_url(password_reset.token)
    self.user = password_reset.user
    mail to: password_reset.email, subject: "Reset your Coyote password"
  end
end
