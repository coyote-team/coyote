# Creates invitations for users to join organizations (works with new and pre-existing users)
# @see Invitation
# @see InvitationMailer
# @see InvitationPolicy
class InvitationsController < ApplicationController
  before_action :authenticate_user!

  helper_method :invitation

  attr_writer :user_invitation_service

  # GET /organizations/1/invitations/new
  def new
    self.invitation = Invitation.new
    authorize invitation
  end

  # POST /create
  def create
    self.invitation = Invitation.new(invitation_params)
    authorize invitation

    user_invitation_service.call(invitation) do |err_msg|
      logger.warn "Unable to create Invitation: #{err_msg}"
      flash.now[:error] = err_msg
      render :new
      return nil
    end

    logger.info "Created #{invitation} for #{invitation.recipient_email} to #{invitation.organization}"
    redirect_to organization_url(current_organization), notice: "Invitation sent to #{invitation.recipient_email}"
  end

  private

  attr_accessor :invitation

  def invitation_params
    params.require(:invitation).permit(:recipient_email,:role)
  end

  def user_invitation_service
    @user_invitation_service ||= UserInvitationService.new(current_user,current_organization)
  end
end
