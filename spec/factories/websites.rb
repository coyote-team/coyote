# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  title      :string
#  url        :string
#  created_at :datetime
#  updated_at :datetime
#  strategy   :string
#

FactoryGirl.define do
  factory :website do
    title "MCA"
    url { Faker::Internet.url }
  end
end
