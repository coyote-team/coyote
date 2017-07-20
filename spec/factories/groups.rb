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
  factory :group do
    title Faker::Lorem.word
  end
end
