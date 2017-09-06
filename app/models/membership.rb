# == Schema Information
#
# Table name: memberships
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role            :enum             default("guest"), not null
#
# Indexes
#
#  index_memberships_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#

# Represents a user belonging to one or more organizations
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum role: {
    guest:  'guest',
    viewer: 'viewer',
    author: 'author',
    editor: 'editor',
    admin:  'admin',
    owner:  'owner'
  }

  # Iterates through all possible Membership roles
  # @yieldparam role_human_name [String]
  # @yieldparam role_name [Symbol]
  def self.each_role
    roles.each_key do |role_name|
      yield role_name.humanize, role_name.to_sym if block_given?
    end
  end

  # @return [Array<Symbol>] list of role names
  def self.role_names
    roles.keys.map(&:to_sym)
  end
end
