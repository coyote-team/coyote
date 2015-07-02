# == Schema Information
#
# Table name: statuses
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text(65535)
#  created_at  :datetime
#  updated_at  :datetime
#

class Status < ActiveRecord::Base
  has_many :descriptions

  validates_presence_of :title

  def to_s
    title
  end
end
