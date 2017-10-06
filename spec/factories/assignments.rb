# == Schema Information
#
# Table name: assignments
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#  resource_id :integer          not null
#
# Indexes
#
#  index_assignments_on_resource_id_and_user_id  (resource_id,user_id) UNIQUE
#

FactoryGirl.define do
  factory :assignment do
    user 
    resource
  end
end
