# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  authentication_token   :string           not null
#  staff                  :boolean          default(FALSE), not null
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  organizations_count    :integer          default(0)
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#

FactoryGirl.define do
  sequence :token do
    SecureRandom.hex(3)
  end

  factory :user do
    authentication_token { generate(:token) }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }

    transient do
      organization nil
      role :guest
    end

    trait :with_membership do
      after(:create) do |user, evaluator|
        create(:membership, user: user, role: evaluator.role)
      end
    end

    trait :staff do
      staff true
    end

    after(:create) do |user, evaluator|
      create(:membership, user: user, organization: evaluator.organization, role: evaluator.role) if evaluator.organization
    end
  end
end
