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
#  index_assignments_on_image_id  (image_id)
#  index_assignments_on_user_id   (user_id)
#

class Assignment < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :image, counter_cache: true, touch: true

  validates_associated :user, :image
  validates_presence_of :user, :image

  validates :user, uniqueness: {scope: :image}
  
  scope :by_created_at, -> { order(:created_at => :desc) }

  paginates_per 50

  def to_s
    user.to_s + " assigned to " + image.to_s
  end
end
