# frozen_string_literal: true

module Api
  # Handles API calls for Representations
  class MembershipsController < Api::ApplicationController
    before_action :authorize_general_access, only: %i[index]
    before_action :find_membership, only: %i[destroy]

    resource_description do
      short "Members of an organization"
      formats %w[json]
    end
    serializes serializable_membership

    def_param_group :membership do
      param(:membership, Hash, action_aware: true) do
        param :email, String, "The email to send the invite to", required: true
        param :role, Coyote::Membership::ROLES.keys, "The role the member will have in the organization"
      end
    end

    api! "Create a new member for this organization"
    param_group :membership
    returns_serialized :membership
    def create
      membership = current_organization.memberships.joins(:user).find_by(users: {email: params[:email]})
      if membership.present?
        authorize membership, :update?
        # Update the membership record
        membership.active = true
        membership.role = params[:role] if params[:role].present?

        membership.save
        render_membership(membership)
      else
        # Invite the member
        invitation = Invitation.new(
          recipient_email: params[:email],
          role:            params[:role],
        )
        authorize invitation

        invitation_service = UserInvitationService.new(current_user, current_organization)
        invitation_service.call(invitation) do |err_msg|
          logger.warn "Unable to create membership due to '#{invitation.error_sentence}'"
          render jsonapi_errors: invitation.errors, status: :unprocessable_entity
          return :bail
        end

        render_membership(invitation.membership)
      end
    end

    api! "Remove a member from this organization"
    def destroy
      @membership.update_column(:active, false)
      head :no_content
    end

    api! "List all the members in the organization"
    returns_serialized array_of: :membership
    def index
      render({
        jsonapi: current_organization.memberships.active,
      })
    end

    private

    def authorize_general_access
      authorize Membership
    end

    def find_membership
      @membership = current_organization.memberships.active.find(params[:id])
      authorize(@membership)
    end

    def render_membership(membership)
      render({
        jsonapi: membership,
        status:  :created,
      })
    end
  end
end
