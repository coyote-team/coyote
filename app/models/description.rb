# == Schema Information
#
# Table name: descriptions
#
#  id         :integer          not null, primary key
#  locale     :string           default("en")
#  text       :text
#  status_id  :integer          not null
#  image_id   :integer          not null
#  metum_id   :integer          not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  license    :string           default("cc0-1.0")
#
# Indexes
#
#  index_descriptions_on_image_id   (image_id)
#  index_descriptions_on_metum_id   (metum_id)
#  index_descriptions_on_status_id  (status_id)
#  index_descriptions_on_user_id    (user_id)
#

class Description < ApplicationRecord
  require 'net/http'
  include Iso639::Validator

  audited :associated_with => :image

  belongs_to :status
  belongs_to :image, touch: true, counter_cache: true, inverse_of: :descriptions
  belongs_to :metum, :inverse_of => :descriptions
  belongs_to :user, :inverse_of => :descriptions

  validates_associated :image, :status, :metum, :user
  validates_presence_of :image, :status, :metum, :locale, :text, :license
  validates :locale, iso639Code: true, length: { is: 2 } 
  validate :license_exists

  scope :ordered, -> { order(:status_id => :desc,:updated_at => :desc) }

  scope :begun, -> {where(status_id: [1,2])}
  scope :ready_to_review, -> {where("status_id = 1")}
  scope :approved, -> {where("status_id = 2")}
  scope :not_approved, -> {where("status_id = 3")}

  scope :alt, -> {where("metum_id = 1")}
  scope :caption, -> {where("metum_id = 2")}
  scope :long, -> {where("metum_id = 3")}

  # uses Coyote::Strategies::* to trigger updates
  # TODO: this procedure needs to be done async in a worker
  after_commit :patch_image, :update_image

  paginates_per 50

  def to_s
    metum.to_s + " description for " + image.to_s + " by " + user.to_s
  end

  def approved?
    status_id ==2
  end
  def not_approved?
    status_id ==3
  end
  def ready_to_review?
    status_id == 1
  end

  def siblings
    Description.where(image_id: image_id).where.not(id: id)
  end

  def siblings_by(user)
    Description.where(image_id: image_id).where.not(id: id).where(user_id: user.id)
  end

  def update_image
    image.update_status_code
    image.save
    return true
  end

  def patch_image
    s = image.website.get_strategy
    if s
      s.patch(image)
    else
      Rails.logger.info "No strategy available for this description's image"
      return true
    end
  end

  def license_exists
    errors.add(:string, "Must exist") unless available_licenses.include?(license)
  end

  def available_licenses
    ["cc0-1.0", "cc-by-4.0", "cc-by-sa-4.0"]
  end
end
