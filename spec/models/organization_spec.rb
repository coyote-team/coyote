# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                 :integer          not null, primary key
#  footer             :string
#  is_deleted         :boolean          default(FALSE)
#  name               :citext           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  default_license_id :integer          not null
#
# Indexes
#
#  index_organizations_on_is_deleted  (is_deleted)
#  index_organizations_on_name        (name) UNIQUE
#
require "spec_helper"

RSpec.describe Organization do
  it "creates default meta when it is created" do
    organization = described_class.create!(default_license: create(:license, :universal), name: "Test Organization")
    expect(organization.meta.size).to eq(Metum::DEFAULTS.size)
  end
end
