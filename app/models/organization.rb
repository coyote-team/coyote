# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  title      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Represents a group of users, usually associated with a particular institution
class Organization < ApplicationRecord
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :images, :dependent => :restrict_with_exception
  has_many :descriptions, :through => :images
end
