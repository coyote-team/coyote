# == Schema Information
#
# Table name: memberships
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_memberships_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#

FactoryGirl.define do
  factory :membership do
    user
    organization
  end
end
