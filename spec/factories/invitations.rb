# == Schema Information
#
# Table name: invitations
#
#  id                :bigint(8)        not null, primary key
#  recipient_email   :string           not null
#  token             :string           not null
#  sender_user_id    :bigint(8)        not null
#  recipient_user_id :bigint(8)        not null
#  organization_id   :bigint(8)        not null
#  redeemed_at       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  role              :enum             default("viewer"), not null
#
# Indexes
#
#  index_invitations_on_organization_id            (organization_id)
#  index_invitations_on_recipient_email_and_token  (recipient_email,token)
#  index_invitations_on_recipient_user_id          (recipient_user_id)
#  index_invitations_on_sender_user_id             (sender_user_id)
#

FactoryBot.define do
  factory :invitation do
    recipient_email { Faker::Internet.unique.email }

    sender_user do
      build(:user, organization: organization)
    end

    recipient_user do
      build(:user, organization: organization)
    end

    organization do
      build(:organization)
    end

    trait :redeemed do
      redeemed_at Time.new(2017, 9, 10, 13, 52)
    end

    Coyote::Membership.each_role do |_, role_name|
      trait role_name do
        role role_name
      end
    end

    before(:create) do |invitation|
      invitation.organization.save!
      invitation.sender_user.save!
      invitation.recipient_user.save!
    end
  end
end
