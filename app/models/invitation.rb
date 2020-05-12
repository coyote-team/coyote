# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations
#
#  id                :bigint           not null, primary key
#  recipient_email   :string           not null
#  redeemed_at       :datetime
#  role              :enum             default("viewer"), not null
#  token             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :bigint           not null
#  recipient_user_id :bigint           not null
#  sender_user_id    :bigint           not null
#
# Indexes
#
#  index_invitations_on_organization_id            (organization_id)
#  index_invitations_on_recipient_email_and_token  (recipient_email,token)
#  index_invitations_on_recipient_user_id          (recipient_user_id)
#  index_invitations_on_sender_user_id             (sender_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (recipient_user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (sender_user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#

# Represents an invitation from a member of one organization to another user
class Invitation < ApplicationRecord
  has_secure_token :token

  validates :recipient_email, presence: true

  belongs_to :sender_user, class_name: "User"
  belongs_to :recipient_user, class_name: "User"
  belongs_to :organization

  enum role: Coyote::Membership::ROLES

  attr_accessor :first_name
  attr_accessor :last_name

  # @raise [Coyote::SecurityError]
  def redeem!
    raise Coyote::SecurityError, "that token has already been used" if redeemed?
    update!(redeemed_at: Time.zone.now)
  end

  # @return [Boolean] if this invitation has been redeemed
  def redeemed?
    !!redeemed_at
  end

  def role_rank
    Coyote::Membership.role_rank(role)
  end

  # @return [String] identifies the organization that sent this invitation
  delegate :name, to: :organization, prefix: true

  # @return [String] identifies the user who sent this invitation
  # @see User#to_s
  def sender_name
    sender_user.to_s
  end
end
