# frozen_string_literal: true

require "spec_helper"

RSpec.describe Organization do
  it "creates default meta when it is created" do
    organization = described_class.create!(default_license: create(:license, :universal), name: "Test Organization")
    expect(organization.meta.size).to eq(Metum::DEFAULTS.size)
  end
end
