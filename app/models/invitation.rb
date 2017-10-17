# == Schema Information
#
# Table name: invitations
#
#  id                :integer          not null, primary key
#  recipient_email   :string           not null
#  token             :string           not null
#  sender_user_id    :integer          not null
#  recipient_user_id :integer          not null
#  organization_id   :integer          not null
#  redeemed_at       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  role              :enum             default("viewer"), not null
#
# Indexes
#
#  index_invitations_on_organization_id            (organization_id)
#  index_invitations_on_recipient_email_and_token  (recipient_email,token)
#  index_invitations_on_recipient_user_id          (recipient_user_id)
#  index_invitations_on_sender_user_id             (sender_user_id)
#

# Represents an invitation from a member of one organization to another user
class Invitation < ApplicationRecord
  has_secure_token :token

  validates :recipient_email, presence: true

  belongs_to :sender_user, class_name: 'User'
  belongs_to :recipient_user, class_name: 'User'
  belongs_to :organization

  enum role: Coyote::Membership::ROLES

  attr_accessor :first_name
  attr_accessor :last_name

  def role_rank
    Coyote::Membership.role_rank(role)
  end

  # @raise [Coyote::SecurityError]
  def redeem!
    raise Coyote::SecurityError, "that token has already been used" if redeemed?
    update_attributes!(redeemed_at: Time.now)
  end

  # @return [Boolean] if this invitation has been redeemed
  def redeemed?
    !!redeemed_at
  end

  # @return [String] identifies the user who sent this invitation
  # @see User#to_s
  def sender_name
    sender_user.to_s
  end

  # @return [String] identifies the organization that sent this invitation
  def organization_title
    organization.title
  end
end
