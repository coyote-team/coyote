class InvitationMailer < ApplicationMailer
  helper_method :invitation, :sender_name, :signup_link

  def new_user(invitation)
    self.invitation = invitation
    self.signup_link = new_registration_url(token: invitation.token)
    mail to: invitation.recipient_email
  end

  def existing_user(invitation)
    self.invitation = invitation
    mail to: invitation.recipient_email
  end

  private
  
  attr_accessor :invitation, :signup_link

  def sender_name
    invitation.sender_name
  end
end
