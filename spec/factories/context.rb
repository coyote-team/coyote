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

    %i[collection website exhibitions events].each do |trait_name|
      trait trait_name do
        title trait_name
      end
    end
  end
end
