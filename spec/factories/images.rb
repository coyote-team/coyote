# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  path               :string(255)
#  canonical_id       :string(255)
#  title              :text(65535)
#  priority           :boolean          default(FALSE)
#  status_code        :integer          default(0)
#  page_urls          :text(65535)
#  website_id         :integer
#  group_id           :integer
#  assignments_count  :integer          default(0)
#  descriptions_count :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_images_on_group_id    (group_id)
#  index_images_on_website_id  (website_id)
#

FactoryGirl.define do
  factory :image do
    page_urls [ "http://whatever.com"   ]
    path { Faker::Internet.url }
    canonical_id { Faker::Crypto.md5 }
    title { Faker::Hipster.sentence(3) } 
    website 
    group 

    trait :priority do
      priority true
    end
  end
end
