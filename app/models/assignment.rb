# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  resource_id :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_assignments_on_resource_id_and_user_id  (resource_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (resource_id => resources.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#

class Assignment < ApplicationRecord
  belongs_to :user, inverse_of: :assignments
  belongs_to :resource, inverse_of: :assignments

  validates :user, uniqueness: {scope: :resource}

  scope :by_created_at, -> { order(created_at: :desc) }

  delegate :name, to: :resource, prefix: true
  delegate :first_name, :last_name, :email, to: :user, prefix: true

  # @return [String] human-friendly representation of this Assignment
  def to_s
    "#{user} assigned to #{resource}"
  end
end
