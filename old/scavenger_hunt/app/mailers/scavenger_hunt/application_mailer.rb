# frozen_string_literal: true

module ScavengerHunt
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    layout "mailer"
  end
end
