# == Schema Information
#
# Table name: descriptions
#
#  id         :integer          not null, primary key
#  locale     :string           default("en")
#  text       :text
#  status_id  :integer          not null
#  image_id   :integer          not null
#  metum_id   :integer          not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  license    :string           default("cc0-1.0")
#
# Indexes
#
#  index_descriptions_on_image_id   (image_id)
#  index_descriptions_on_metum_id   (metum_id)
#  index_descriptions_on_status_id  (status_id)
#  index_descriptions_on_user_id    (user_id)
#

FactoryGirl.define do
  factory :description do
    locale "en"
    text Faker::Lorem.paragraph
    status
    image
    metum
    user

    trait :ready_to_review do
      association :status, factory: :ready_to_review_status
    end

    trait :approved do
      association :status, factory: :approved_status
    end

    trait :not_approved do
      association :status, factory: :not_approved_status
    end
  end
end
