# frozen_string_literal: true

# Responsible for associating new or existing users with an organization
# @see InvitationsController
class UserInvitationService
  # @param user [User] the user being invited
  # @param organization [Organization] the organization the user is joining
  def initialize(user, organization)
    @user = user
    @organization = organization
  end

  # Find or create the recipient user, and create an invitation
  # @param invitation [Invitation]
  # @yieldparam err_msg [String] describes errors that prevent inviting the user
  def call(invitation)
    dummy_password = SecureRandom.hex(20)

    create_params = {
      password:   dummy_password,
      first_name: invitation.first_name,
      last_name:  invitation.last_name,
    }

    recipient_user = User
      .create_with(create_params)
      .find_or_initialize_by(email: invitation.recipient_email)

    if organization.users.exists?(recipient_user.id)
      yield "#{recipient_user} is already a member of #{organization.name}"
      return
    end

    invitation.recipient_user = recipient_user
    invitation.sender_user = user
    invitation.organization = organization

    Invitation.transaction do
      delivery_method = if recipient_user.new_record?
        recipient_user.save!
        :new_user
      else
        :existing_user
      end

      if invitation.save
        membership = organization.memberships.find_or_create_by!(user: recipient_user, role: invitation.role)
        Rails.logger.info "Created #{membership}"
        InvitationMailer.public_send(delivery_method, invitation).deliver_now
      else
        yield invitation.error_sentence
      end
    end

    invitation
  end

  private

  attr_reader :user, :organization
end
