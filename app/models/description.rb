# == Schema Information
#
# Table name: descriptions
#
#  id         :integer          not null, primary key
#  locale     :string(255)      default("en")
#  text       :text(65535)
#  status_id  :integer
#  image_id   :integer
#  metum_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_descriptions_on_image_id   (image_id)
#  index_descriptions_on_metum_id   (metum_id)
#  index_descriptions_on_status_id  (status_id)
#  index_descriptions_on_user_id    (user_id)
#

class Description < ActiveRecord::Base

  belongs_to :status
  belongs_to :image, touch: true
  belongs_to :metum
  belongs_to :user

  validates_associated :image, :status, :metum, :user
  validates_presence_of :image, :status, :metum, :locale, :text

  default_scope {order('status_id ASC')}

  scope :ready_to_review, -> {where("status_id = 1")}
  scope :approved, -> {where("status_id = 2")}
  scope :not_approved, -> {where("status_id = 3")}

  scope :alt, -> {where("metum_id = 1")}
  scope :caption, -> {where("metum_id = 2")}
  scope :long, -> {where("metum_id = 3")}

  def to_s
    metum.title + " description for " + image.to_s + " by " + user.to_s
  end
end
