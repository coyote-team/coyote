# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  active               :boolean          default(TRUE)
#  authentication_token :string           not null
#  current_sign_in_at   :datetime
#  current_sign_in_ip   :string
#  email                :citext           default(""), not null
#  encrypted_password   :string           default(""), not null
#  failed_attempts      :integer          default(0), not null
#  first_name           :citext
#  last_name            :citext
#  last_sign_in_at      :datetime
#  last_sign_in_ip      :string
#  locked_at            :datetime
#  organizations_count  :integer          default(0)
#  password_digest      :string
#  sign_in_count        :integer          default(0), not null
#  staff                :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#

class User < ApplicationRecord
  MINIMUM_PASSWORD_LENGTH = 8

  attr_accessor :current_password, :password_confirmation, :remember_me

  has_secure_password validations: false
  has_secure_token :authentication_token

  has_many :auth_tokens, dependent: :destroy
  has_many :password_resets, dependent: :destroy
  has_one :current_password_reset, -> { unexpired }, class_name: "PasswordReset", inverse_of: :user

  has_many :memberships, dependent: :destroy
  has_many :organizations, -> { is_active }, through: :memberships, counter_cache: :organizations_count

  has_many :assignments, inverse_of: :user, dependent: :restrict_with_exception
  has_many :assigned_resources, -> { where.not(assignments: {status: :deleted}) }, class_name: :Resource, through: :assignments, source: :resource
  has_many :authored_representations, dependent: :restrict_with_exception, inverse_of: :author, foreign_key: :author_id, class_name: :Representation
  has_many :imports, dependent: :restrict_with_exception
  has_many :organization_representations, through: :organizations, class_name: :Representation, source: :representations
  has_many :resources, through: :organizations
  has_many :representations, through: :resources
  has_many :resource_links, through: :organizations
  has_many :resource_groups, through: :organizations

  has_one_attached :profile_picture

  scope :active, -> { where(active: true) }
  scope :can_author, -> { references(:memberships).where.not(memberships: {role: %w[guest viewer]}) }
  scope :sorted, -> { order(Arel.sql("LOWER(users.last_name) ASC NULLS LAST, LOWER(users.first_name) ASC NULLS LAST, LOWER(users.email) ASC, users.id ASC")) }

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true
  validates :email, uniqueness: true, if: :email_changed?
  validates :password, length: {minimum: MINIMUM_PASSWORD_LENGTH}, presence: true, if: :password_required?
  validates :password, confirmation: true, if: :password_confirmation_required?
  validate :current_password_is_correct

  def self.find_for_authentication(warden_conditions)
    find_by(warden_conditions.merge(active: true))
  end

  def access_locked?
    failed_attempts >= Rails.application.config.x.maximum_login_attempts
  end

  def avatar_url
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.to_s)}?d=retro&s=80"
  end

  def full_name_and_email
    name == email ? email : "#{name} (#{email})"
  end

  # @return [String] human-friendly name for this user, depending on which of the name columns are filled-in; falls back to email address
  def to_s
    if first_name.present? || last_name.present?
      [first_name.presence, last_name.presence].compact.join(" ")
    else
      email
    end
  end

  alias_method :name, :to_s

  def update_organization_counter_cache
    update_attribute(:organizations_count, organizations.count(true))
  end

  # @note for audit log
  def username
    to_s
  end

  private

  def current_password_is_correct
    errors.add(:current_password, "is required") if !current_password.nil? && current_password.blank?
    errors.add(:current_password, "is incorrect") if current_password.present? && !authenticate(current_password)
  end

  def password_confirmation_required?
    password.present? && !password_confirmation.nil?
  end

  def password_required?
    # New users are required to set a password
    !persisted? ||
      # Passwords are validated if provided
      password.present? || password_confirmation.present?
  end
end
