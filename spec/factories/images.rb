# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  path               :string
#  website_id         :integer          not null
#  context_id         :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#  canonical_id       :string
#  assignments_count  :integer          default(0), not null
#  descriptions_count :integer          default(0), not null
#  title              :text
#  priority           :boolean          default(FALSE), not null
#  status_code        :integer          default(0), not null
#  page_urls          :string           not null, is an Array
#  organization_id    :integer          not null
#
# Indexes
#
#  index_images_on_context_id       (context_id)
#  index_images_on_organization_id  (organization_id)
#  index_images_on_website_id       (website_id)
#

FactoryGirl.define do
  factory :image do
    page_urls ["http://whatever.com"]
    path { Faker::Internet.url }
    canonical_id { Faker::Crypto.md5 }
    title { Faker::Hipster.sentence(3) } 
    website 
    context 
    organization

    trait :priority do
      priority true
    end
  end
end
