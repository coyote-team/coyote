# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :context do
    title { Faker::Lorem.unique.word }
    organization
  end
end
