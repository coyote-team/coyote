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
  include Iso639::Validator
  belongs_to :status
  belongs_to :image, touch: true
  belongs_to :metum
  belongs_to :user

  validates_associated :image, :status, :metum, :user
  validates_presence_of :image, :status, :metum, :locale, :text
  validates :locale, iso639Code: true, length: { is: 2 } 


  default_scope {order('status_id ASC')}

  scope :ready_to_review, -> {where("status_id = 1")}
  scope :approved, -> {where("status_id = 2")}
  scope :not_approved, -> {where("status_id = 3")}

  scope :alt, -> {where("metum_id = 1")}
  scope :caption, -> {where("metum_id = 2")}
  scope :long, -> {where("metum_id = 3")}

  paginates_per 50

  def to_s
    metum.title + " description for " + image.to_s + " by " + user.to_s
  end

  def approved?
    status_id ==2
  end
  def not_approved?
    status_id ==3
  end
  def ready_to_review
    status_id == 1
  end

  def siblings
    Description.where(image_id: image_id).where.not(id: id)
  end

  def siblings_by(user)
    Description.where(image_id: image_id).where.not(id: id).where(user_id: user.id)
  end

end
