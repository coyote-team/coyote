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
#  admin                  :boolean          default(FALSE)
#  first_name             :string
#  last_name              :string
#  authentication_token   :string
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

  scope :sorted, -> { order('LOWER(last_name) asc') }

  def to_s
    if !first_name.blank? or !last_name.blank?
      [first_name, last_name].join(' ')
    else
      email
    end
  end

  #def sorted
    #all.sort{|a,b| a.last_name.dropcase <=> a.last_name.dropcase}
  #end

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

  #NOTE for audit log
  def username 
    to_s
  end
end
