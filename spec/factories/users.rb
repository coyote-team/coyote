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
#  authentication_token   :string
#  role                   :enum             default("viewer"), not null
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role                  (role)
#

FactoryGirl.define do
  sequence :token do
    SecureRandom.hex(3)
  end

  factory :user do
    authentication_token { generate(:token) }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }

    User.roles.keys.each do |role_name|
      trait role_name.to_sym do
        role role_name
      end
    end

    factory :user_with_memberships do
      transient do
        membership_count 3
      end

      after(:create) do |user,evaluator|
        create_list(:membership,evaluator.membership_count,user: user)
      end
    end
  end
end
