# == Schema Information
#
# Table name: memberships
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role            :enum             default("guest"), not null
#
# Indexes
#
#  index_memberships_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#

FactoryGirl.define do
  factory :membership do
    user
    organization

    Membership.each_role.each do |_,role_name|
      trait role_name do
        role role_name
      end
    end
  end
end
