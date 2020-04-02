# frozen_string_literal: true

RSpec.describe "Viewing static pages" do
  it "works for the root path" do
    visit root_path
    expect(page).to have_current_path("/")
  end

  it "works for the support page" do
    visit support_path
    expect(page).to have_current_path("/support")
  end
end
