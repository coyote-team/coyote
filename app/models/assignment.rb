# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id          :integer          not null, primary key
#  status      :integer          default("pending"), not null
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

  validates :user, uniqueness: {scope: :resource}, if: :user_id_changed?

  scope :active, -> {
    includes(:user)
      .references(:user)
      .where(users: {active: true})
      .not_deleted
  }
  scope :by_created_at, -> { order(created_at: :desc) }
  scope :by_priority, -> { joins(:resource).order("resources.representations_count ASC") }
  scope :not_deleted, -> { where.not(status: :deleted) }
  scope :by_user_name, ->(direction = :asc) {
    includes(:user)
      .references(:user)
      .order("last_name" => direction)
      .order("email" => direction)
  }

  delegate :name, to: :resource, prefix: true
  delegate :first_name, :last_name, :email, to: :user, prefix: true

  enum status: {
    pending:  0,
    complete: 10,
    deleted:  20,
  }

  def infer_status!
    representations = resource.representations.where(author_id: user_id)
    inferred_status = if representations.none?
      :pending
    elsif representations.where.not(status: :not_approved).any?
      :complete
    else
      :deleted
    end
    update_attribute(:status, inferred_status)
  end

  # @return [String] human-friendly representation of this Assignment
  def to_s
    "#{user} assigned to #{resource}"
  end
end
