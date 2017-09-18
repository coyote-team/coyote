# == Schema Information
#
# Table name: assignments
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  image_id   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_assignments_on_user_id_and_image_id  (user_id,image_id) UNIQUE
#

FactoryGirl.define do
  factory :assignment do
    user 
    image 
  end
end
