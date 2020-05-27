# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                 :integer          not null, primary key
#  name               :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  default_license_id :integer          not null
#
# Indexes
#
#  index_organizations_on_name  (name) UNIQUE
#

FactoryBot.define do
  factory :organization do
    name { Faker::Company.unique.name }
    default_license_id { License.all.first_id || create(:license, :universal).id }
  end
end
