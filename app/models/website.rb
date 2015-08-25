# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Website < ActiveRecord::Base
  validates_presence_of :title, :url
  validates_url :url
  has_many :images, dependent: :nullify

  def to_s
    title
  end
end
