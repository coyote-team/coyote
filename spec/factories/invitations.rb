# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations
#
#  id                :bigint           not null, primary key
#  recipient_email   :citext           not null
#  redeemed_at       :datetime
#  role              :enum             default("viewer"), not null
#  token             :citext           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :bigint           not null
#  recipient_user_id :bigint           not null
#  sender_user_id    :bigint           not null
#
# Indexes
#
#  index_invitations_on_organization_id            (organization_id)
#  index_invitations_on_recipient_email_and_token  (recipient_email,token)
#  index_invitations_on_recipient_user_id          (recipient_user_id)
#  index_invitations_on_sender_user_id             (sender_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (recipient_user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (sender_user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
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
      redeemed_at { Time.zone.local(2017, 9, 10, 13, 52) }
    end

    Coyote::Membership.each_role do |_, role_name|
      trait role_name do
        role { role_name }
      end
    end

    before(:create) do |invitation|
      invitation.organization.save!
      invitation.sender_user.save!
      invitation.recipient_user.save!
    end
  end
end
