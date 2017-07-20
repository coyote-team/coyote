# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

class Group < ActiveRecord::Base
  validates_presence_of :title
  has_many :images, dependent: :nullify

  def to_s
    title
  end
end
