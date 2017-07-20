# == Schema Information
#
# Table name: statuses
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

class Status < ActiveRecord::Base
  has_many :descriptions

  validates_presence_of :title

  def to_s
    title
  end
end
