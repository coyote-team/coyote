# frozen_string_literal: true

# == Schema Information
#
# Table name: password_resets
#
#  id         :bigint           not null, primary key
#  expires_at :datetime         not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_password_resets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PasswordReset < ApplicationRecord
  DEFAULT_EXPIRATION = 15.minutes.freeze

  belongs_to :user
  delegate :email, to: :user

  has_secure_token

  before_create :set_expires_at
  after_create :send_password_reset_instructions

  scope :unexpired, -> { where("expires_at < ?", Time.zone.now) }

  def expired?
    expires_at < Time.zone.now
  end

  private

  def send_password_reset_instructions
    SendPasswordResetWorker.perform_async(id)
  end

  def set_expires_at
    self.expires_at = DEFAULT_EXPIRATION.from_now
  end
end
