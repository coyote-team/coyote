# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_groups
#
#  id              :integer          not null, primary key
#  default         :boolean          default(FALSE)
#  name            :string           not null
#  webhook_uri     :string
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_name  (organization_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => cascade ON UPDATE => cascade
#

FactoryBot.define do
  factory :resource_group do
    name { Faker::Lorem.unique.word }
    organization

    %i[collection website exhibitions events].each do |trait_name|
      trait trait_name do
        name { trait_name }
      end
    end
  end
end
