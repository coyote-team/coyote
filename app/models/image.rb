# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  url        :string(255)
#  website_id :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_images_on_website_id  (website_id)
#

class Image < ActiveRecord::Base
  belongs_to :website
  has_many :descriptions, dependent: :destroy

  validates :url, :presence => true, :uniqueness => {:scope => :website_id}
  validates_associated :website

  def to_s
    url
  end
  def full_url
    if website
      website.url + url
    end
  end
end
