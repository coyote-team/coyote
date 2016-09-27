# == Schema Information
#
# Table name: meta
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  instructions :text(65535)
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :metum do
    title "MyString"
    instructions Faker::Lorem.sentence
  end
end
