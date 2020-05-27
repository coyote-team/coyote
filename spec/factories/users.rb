# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  active                 :boolean          default(TRUE)
#  authentication_token   :string           not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :citext           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :citext
#  last_name              :citext
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  organizations_count    :integer          default(0)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  staff                  :boolean          default(FALSE), not null
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#

FactoryBot.define do
  sequence :token do
    SecureRandom.hex(3)
  end

  factory :user do
    authentication_token { generate(:token) }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }

    transient do
      organization { nil }
      role { :guest }
    end

    trait :with_membership do
      after(:create) do |user, evaluator|
        create(:membership, user: user, role: evaluator.role)
      end
    end

    trait :staff do
      staff { true }
    end

    after(:create) do |user, evaluator|
      create(:membership, user: user, organization: evaluator.organization, role: evaluator.role) if evaluator.organization
    end
  end
end
