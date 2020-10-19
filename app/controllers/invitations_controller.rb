# frozen_string_literal: true

# Creates invitations for users to join organizations (works with new and pre-existing users)
# @see Invitation
# @see InvitationMailer
# @see InvitationPolicy
class InvitationsController < ApplicationController
  helper_method :invitation, :title

  # POST /create
  def create
    self.invitation = Invitation.new(invitation_params)
    authorize invitation

    user_invitation_service.call(invitation) do |err_msg|
      self.title = "Inviting a user to join #{current_organization.name}"
      logger.warn "Unable to create Invitation: #{err_msg}"
      flash.now[:error] = err_msg
      render :new
      return :unable_to_create_invitation # avoid leaking nil
    end

    logger.info "Created #{invitation} for #{invitation.recipient_email} to #{invitation.organization}"
    redirect_to organization_path(current_organization), notice: "#{invitation.recipient_user.full_name_and_email} has been invited as a #{invitation.role} to the #{current_organization.name} organization"
  end

  # GET /organizations/1/invitations/new
  def new
    self.title = "Invite a user to join #{current_organization.name}"
    self.invitation = Invitation.new
    authorize invitation
  end

  private

  attr_accessor :invitation, :title

  def invitation_params
    params.require(:invitation).permit(:recipient_email, :role, :first_name, :last_name)
  end

  def user_invitation_service
    @user_invitation_service ||= UserInvitationService.new(current_user, current_organization)
  end
end
