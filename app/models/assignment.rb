# == Schema Information
#
# Table name: assignments
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#  resource_id :integer          not null
#
# Indexes
#
#  index_assignments_on_resource_id_and_user_id  (resource_id,user_id) UNIQUE
#

class Assignment < ApplicationRecord
  belongs_to :user, :inverse_of => :assignments
  belongs_to :resource, :inverse_of => :assignments

  validates :user, uniqueness: { :scope => :resource }
  
  scope :by_created_at, -> { order(:created_at => :desc) }

  delegate :title, :to => :resource, :prefix => true
  delegate :first_name, :last_name, :email, :to => :user, :prefix => true

  paginates_per 50

  # @return [String] human-friendly representation of this Assignment
  def to_s
    "#{user} assigned to #{resource}"
  end
end
