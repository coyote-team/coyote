# frozen_string_literal: true

# == Schema Information
#
# Table name: auth_tokens
#
#  id         :bigint           not null, primary key
#  expires_at :datetime         not null
#  token      :string
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_auth_tokens_on_token              (token)
#  index_auth_tokens_on_token_and_user_id  (token,user_id)
#  index_auth_tokens_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AuthToken < ApplicationRecord
  DEFAULT_EXPIRATION = 30.days.freeze
  KEY = "auth_token"

  belongs_to :user

  has_secure_token

  before_create :set_expires_at

  scope :active, -> { where("expires_at > ?", Time.zone.now) }

  private

  def set_expires_at
    self.expires_at = DEFAULT_EXPIRATION.from_now
  end
end
