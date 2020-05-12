# frozen_string_literal: true

# Handles new user signup; since new users get created during the invitaitons process, this controller
# merely serves up a 'new user' form, which updates the invited user's account with new password and potentially
# a different email address
class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!

  helper_method :invitation, :user

  # GET /users/sign_up?token=abc123
  # Render invitation acceptance form
  def new
    token = params.require(:token)
    return unless setup_invitation(token)

    flash.now[:notice] = "Welcome to Coyote! After completing this form, you will become a member of the #{invitation.organization_name} organization."
  end

  # PATCH /users
  # Update the invited user's account with password and email address
  # @see Devise::RegistrationController#update
  def update
    token = user_attributes.delete(:token)
    return unless setup_invitation(token)

    user = invitation.recipient_user

    if user.update(user_attributes.except(:token))
      logger.info "Successfully completed registration of #{user} for #{invitation}"
      invitation.redeem!
      sign_in(user) # Devise helper so user doesn't have to sign-in again; now the invited user is current_user
      redirect_to invitation.organization, notice: "Welcome to Coyote! You are now a member of the #{invitation.organization_name} organization."
    else
      logger.warn "Unable to complete registration for #{user} due to '#{user.error_sentence}'"
      render :new
    end
  end

  private

  attr_accessor :invitation, :user

  def setup_invitation(token)
    self.invitation = Invitation.find_by!(token: token)
    self.user = invitation.recipient_user

    if invitation.redeemed?
      logger.error "Attempt to use previously-redeemed #{invitation}"
      redirect_to new_user_session_url, alert: %(We're sorry, but that invitation has already been used.)
      false
    else
      true
    end
  end

  def user_attributes
    params.require(:user).permit(:email, :password, :password_confirmation, :token)
  end
end
