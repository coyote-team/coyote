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
      invitation_params = {
        recipient_email: params[:email],
        role:            params[:role],
      }
      invitation = Invitation.new(invitation_params)
      authorize invitation

      invitation_service = UserInvitationService.new(current_user, current_organization)
      invitation_service.call(invitation) do |err_msg|
        logger.warn "Unable to create membership due to '#{invitation.error_sentence}'"
        render jsonapi_errors: invitation.errors, status: :unprocessable_entity
        return :bail
      end

      render({
        jsonapi: invitation.membership,
        status:  :created,
      })
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
        jsonapi: current_organization.memberships,
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
  end
end
