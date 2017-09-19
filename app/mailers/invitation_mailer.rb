class InvitationMailer < ApplicationMailer
  helper_method :invitation, :sender_name, :signup_link, :organization_title

  def new_user(invitation)
    self.invitation = invitation
    self.signup_link = new_registration_url(token: invitation.token)
    mail to: invitation.recipient_email, subject: subject
  end

  def existing_user(invitation)
    self.invitation = invitation
    mail to: invitation.recipient_email, subject: subject
  end

  private
  
  attr_accessor :invitation, :signup_link

  def sender_name
    invitation.sender_name
  end

  def organization_title
    invitation.organization_title
  end

  def subject 
    "#{Rails.configuration.x.site_name}: Invitation to join '#{organization_title}'"
  end
end
