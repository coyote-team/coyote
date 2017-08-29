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
  has_many :memberships, :inverse_of => :organization
  has_many :users, :through => :memberships
  has_many :images, :dependent => :restrict_with_exception, :inverse_of => :organization
  has_many :descriptions, :through => :images
  has_many :contexts, :inverse_of => :organization
  has_many :websites, :inverse_of => :organization
  has_many :assignments, :through => :images
end
