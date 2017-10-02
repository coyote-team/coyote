# == Schema Information
#
# Table name: licenses
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  title      :string           not null
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :license do
    name { Faker::Lorem.unique.word }
    title { Faker::Lorem.paragraph }
    url 'https://example.org/license'

    trait :universal do
      name 'cc0-1.0'
      title 'Universal Public Domain Dedication'
      url 'https://creativecommons.org/publicdomain/zero/1.0/'
    end

    trait :attribution_international do
      name 'cc-by-4.0'
      title 'Attribution 4.0 International'
      url 'https://creativecommons.org/licenses/by/4.0/'
    end

    trait :attribution_sharealike_international do
      name 'cc-by-sa-4.0'
      title 'Attribution-ShareAlike 4.0 International'
      url 'https://creativecommons.org/licenses/by-sa/4.0/'
    end
  end
end
