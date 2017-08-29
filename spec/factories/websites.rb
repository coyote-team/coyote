# == Schema Information
#
# Table name: websites
#
#  id              :integer          not null, primary key
#  title           :string
#  url             :string
#  created_at      :datetime
#  updated_at      :datetime
#  strategy        :string
#  organization_id :integer          not null
#
# Indexes
#
#  index_websites_on_organization_id  (organization_id)
#

FactoryGirl.define do
  factory :website do
    title "MCA"
    url { Faker::Internet.url }
    organization
  end
end
