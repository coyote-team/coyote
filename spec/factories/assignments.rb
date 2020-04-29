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

FactoryBot.define do
  factory :assignment do
    user
    resource
  end
end
