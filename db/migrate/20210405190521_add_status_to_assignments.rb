class AddStatusToAssignments < ActiveRecord::Migration[6.0]
  def change
    add_column :assignments, :status, :integer, default: 0, null: false
    Assignment.in_batches.each_record do |assignment|
      representations = assignment.resource.representations.where(author_id: assignment.user_id)
      next unless representations.any?
      assignment.update_attribute(:status, representations.where.not(status: :not_approved).any? ? :complete : :deleted)
    end
  end
end
