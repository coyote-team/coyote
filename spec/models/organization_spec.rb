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
#  index_organizations_on_name        (name) UNIQUE WHERE (is_deleted IS FALSE)
#
# Foreign Keys
#
#  fk_rails_...  (default_license_id => licenses.id)
#
require "spec_helper"

RSpec.describe Organization do
  it "creates default meta when it is created" do
    organization = described_class.create!(default_license: create(:license, :universal), name: "Test Organization")
    expect(organization.meta.size).to eq(Metum::DEFAULTS.size)
  end

  it "validates uniqueness for non-deleted organizations" do
    original_organization = create(:organization, name: "TEST")
    original_organization.update_attribute(:is_deleted, true)
    new_organization = build(:organization, name: "TEST")
    expect(new_organization).to be_valid
  end
end
