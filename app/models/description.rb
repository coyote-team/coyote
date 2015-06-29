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
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_descriptions_on_image_id   (image_id)
#  index_descriptions_on_metum_id   (metum_id)
#  index_descriptions_on_status_id  (status_id)
#

class Description < ActiveRecord::Base
  default_scope {order('status_id ASC')}
  belongs_to :image, touch: true
  belongs_to :status
  belongs_to :metum

  #validates :locale
  #validates :text
  validates_associated :image, :status, :metum
  validates_presence_of :image, :status, :metum, :locale

  def check_text
    #TODO updates status automatically 
    #if unassigned and text empty
      #set status to unassigned
    #if assigned
      #set status to assigned
    #if text no longer empty but was empty
      #set status to ready to review
    #if text changed #TODO or if status changed to completed
      #send patch request to image url
  end
end
