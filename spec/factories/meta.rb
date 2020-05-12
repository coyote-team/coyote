# frozen_string_literal: true

# == Schema Information
#
# Table name: meta
#
#  id              :integer          not null, primary key
#  instructions    :text             default(""), not null
#  name            :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :bigint           not null
#
# Indexes
#
#  index_meta_on_organization_id           (organization_id)
#  index_meta_on_organization_id_and_name  (organization_id,name) UNIQUE
#

FactoryBot.define do
  factory :metum do
    name { Faker::Lorem.unique.word }
    organization
    instructions { "A brief description enabling a user to interact with the image when it is not rendered or when the user has low vision" }

    trait :short do
      name { "Short" }
    end

    trait :long do
      name { "Long" }
      instructions { "A long description is a lengthier text than a traditional alt-text that attempts to provide a comprehensive representation of an image. Long descriptions can range from one sentence to several paragraphs." }
    end
  end
end
