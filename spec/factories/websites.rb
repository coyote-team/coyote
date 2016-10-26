# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#  strategy   :string(255)
#

FactoryGirl.define do
  factory :website do
    title "MCA"
    url {Faker::Internet.url}
  end
end
