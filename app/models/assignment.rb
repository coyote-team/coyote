# == Schema Information
#
# Table name: assignments
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  image_id   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_assignments_on_user_id_and_image_id  (user_id,image_id) UNIQUE
#

class Assignment < ApplicationRecord
  belongs_to :user, :touch => true, :inverse_of => :assignments
  belongs_to :image, :counter_cache => true, :touch => true, :inverse_of => :assignments

  validates :user, uniqueness: { :scope => :image }
  
  scope :by_created_at, -> { order(:created_at => :desc) }

  paginates_per 50

  # @return [String] human-friendly representation of this Assignment
  def to_s
    "#{user} assigned to #{image}"
  end
end
