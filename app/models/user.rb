# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default(FALSE)
#  first_name             :string(255)
#  last_name              :string(255)
#  authentication_token   :string(255)
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, password_length: 8..128

  has_many :assignments, dependent: :destroy
  has_many :images, through: :assignments
  has_many :descriptions, dependent: :nullify

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

  #TODO not working; for audited
  def username 
    to_s
  end
end
