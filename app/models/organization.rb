# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  title      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_on_title  (title) UNIQUE
#

# Represents a group of users, usually associated with a particular institution
class Organization < ApplicationRecord
  validates :title, presence: true, uniqueness: true

  has_many :memberships, :inverse_of => :organization
  has_many :users, :through => :memberships
  has_many :resources, :dependent => :restrict_with_exception, :inverse_of => :organization 
  has_many :contexts, :inverse_of => :organization
  has_many :meta, :inverse_of => :organization
  has_many :assignments, :through => :resources
  has_many :representations, :through => :resources
end
