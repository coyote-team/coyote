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
#  authentication_token   :string
#  role                   :enum             default("guest"), not null
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role                  (role)
#

class User < ApplicationRecord
  acts_as_token_authenticatable

  has_many :memberships
  has_many :organizations, :through => :memberships

  devise :database_authenticatable, 
         :registerable, 
         :recoverable, 
         :rememberable, 
         :trackable, 
         :validatable, 
         :password_length => 8..128

  enum role: {
    guest:       'guest',
    viewer:      'viewer',
    author:      'author',
    editor:      'editor',
    admin:       'admin',
    owner:       'owner',
    staff:       'staff'
  }

  has_many :assignments, dependent: :destroy # TODO: all 3 of these need to be moved into DB foreign key constraint cascades
  has_many :assigned_images, class_name: "Image", through: :assignments
  has_many :images, through: :organizations
  has_many :descriptions, dependent: :nullify

  scope :sorted, -> { order('LOWER(users.last_name) asc') }

  def to_s
    if !first_name.blank? or !last_name.blank?
      [first_name, last_name].join(' ')
    else
      email
    end
  end

  def next_image(current_image=nil)
    next_image = nil
    images.each do |i|
      described_by_me = nil
      described_by_me = i.descriptions.detect{ |d| d.user_id == id}

      if current_image
        if described_by_me.nil?  and current_image.id != i.id
          next_image = i
          break
        end
      elsif described_by_me.nil?
        next_image = i
        break
      end

    end
    next_image
  end

  # @note for audit log
  def username 
    to_s
  end
end
