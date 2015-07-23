# == Schema Information
#
# Table name: images
#
#  id           :integer          not null, primary key
#  path         :string(255)
#  website_id   :integer
#  group_id     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  canonical_id :string(255)
#
# Indexes
#
#  index_images_on_group_id    (group_id)
#  index_images_on_website_id  (website_id)
#

FactoryGirl.define do
  factory :image do
    url "MyString"
website nil
  end

end
