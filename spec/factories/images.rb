# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  path               :string
#  context_id         :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#  canonical_id       :string
#  assignments_count  :integer          default(0), not null
#  descriptions_count :integer          default(0), not null
#  title              :text
#  priority           :boolean          default(FALSE), not null
#  status_code        :integer          default(0), not null
#  old_page_urls      :text
#  organization_id    :integer          not null
#  page_urls          :text             default([]), not null, is an Array
#
# Indexes
#
#  index_images_on_context_id       (context_id)
#  index_images_on_organization_id  (organization_id)
#

FactoryGirl.define do
  factory :image do
    page_urls ["http://whatever.com"]
    path { Faker::Internet.url }
    canonical_id { Faker::Crypto.md5 }
    title { Faker::Hipster.sentence(3) } 
    organization

    transient do
      context nil
    end
    
    before(:create) do |image,evaluator|
      image.context = evaluator.context || build(:context,organization: image.organization)
    end
  end
end
