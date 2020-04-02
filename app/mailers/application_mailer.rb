# frozen_string_literal: true

# @abstract Base from which other mailers derive
class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.x.default_email_from_address
  layout "mailer"
end
