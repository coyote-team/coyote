# frozen_string_literal: true

class InvitationMailer < ApplicationMailer
  helper_method :invitation, :recipient_email, :role, :organization_name, :sender_name, :organization, :signup_link

  def existing_user(invitation)
    self.invitation = invitation
    mail to: invitation.recipient_email, subject: subject
  end

  def new_user(invitation)
    self.invitation = invitation
    self.signup_link = new_registration_url(token: invitation.token)
    mail to: invitation.recipient_email, subject: subject
  end

  private

  attr_accessor :invitation, :signup_link

  def organization
    invitation.organization
  end

  def organization_name
    invitation.organization_name
  end

  def recipient_email
    invitation.recipient_email
  end

  def role
    invitation.role
  end

  def sender_name
    invitation.sender_name
  end

  def subject
    "#{Rails.configuration.x.site_name}: Invitation to join '#{organization_name}'"
  end
end
