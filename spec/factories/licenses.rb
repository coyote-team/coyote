# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id          :bigint           not null, primary key
#  description :string           not null
#  is_default  :boolean          default(FALSE)
#  name        :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :license do
    name { Faker::Lorem.unique.words(number: 3) }
    description { Faker::Lorem.paragraph }
    url { "https://example.org/license" }

    trait :universal do
      name { "cc0-1.0" }
      description { "Universal Public Domain Dedication" }
      is_default { true }
      url { "https://creativecommons.org/publicdomain/zero/1.0/" }
    end

    trait :attribution_international do
      name { "cc-by-4.0" }
      description { "Attribution 4.0 International" }
      url { "https://creativecommons.org/licenses/by/4.0/" }
    end

    trait :attribution_sharealike_international do
      name { "cc-by-sa-4.0" }
      description { "Attribution-ShareAlike 4.0 International" }
      url { "https://creativecommons.org/licenses/by-sa/4.0/" }
    end
  end
end
