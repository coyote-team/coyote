# == Schema Information
#
# Table name: endpoints
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_endpoints_on_name  (name) UNIQUE
#

FactoryBot.define do
  factory :endpoint do
    name do
      "Website #{SecureRandom.hex(3)}"
    end

    trait :any do
      name 'Any'
    end

    trait :website do
      name 'Website'
    end

    trait :kiosk do
      name 'Kiosk'
    end
  end
end
