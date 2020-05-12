# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_on_name  (name) UNIQUE
#

FactoryBot.define do
  factory :organization do
    name { Faker::Company.unique.name }
  end
end
