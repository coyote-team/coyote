# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  authentication_token   :string           not null
#  staff                  :boolean          default(FALSE), not null
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  organizations_count    :integer          default(0)
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#

class User < ApplicationRecord
  has_secure_token :authentication_token

  has_many :memberships
  has_many :organizations, through: :memberships, counter_cache: :organizations_count

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable,
         :password_length => 8..128

  has_many :assignments, :inverse_of => :user, :dependent => :destroy
  has_many :assigned_resources, :class_name => :Resource, :through => :assignments, :source => :resource
  has_many :authored_representations, :dependent => :restrict_with_exception, :inverse_of => :author, :foreign_key => :author_id, :class_name => :Representation
  has_many :organization_representations, :through => :organizations, :class_name => :Representation, :source => :representations
  has_many :resources, :through => :organizations
  has_many :representations, :through => :resources
  has_many :resource_links, :through => :organizations
  has_many :resource_groups, :through => :organizations

  scope :sorted, -> { order('LOWER(users.last_name) asc') }

  # @return [String] human-friendly name for this user, depending on which of the name columns are filled-in; falls back to email address
  def to_s
    if !first_name.blank? || !last_name.blank?
      [first_name, last_name].join(' ')
    else
      email
    end
  end

  alias name to_s

  # @note for audit log
  def username
    to_s
  end
end
