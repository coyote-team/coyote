# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                               :integer          not null, primary key
#  allow_authors_to_claim_resources :boolean          default(FALSE), not null
#  footer                           :string
#  is_deleted                       :boolean          default(FALSE)
#  name                             :citext           not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  default_license_id               :integer          not null
#
# Indexes
#
#  index_organizations_on_is_deleted  (is_deleted)
#  index_organizations_on_name        (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (default_license_id => licenses.id)
#

FactoryBot.define do
  factory :organization do
    name { Faker::Company.unique.name }
    default_license_id { License.all.first_id || create(:license, :universal).id }
  end
end
