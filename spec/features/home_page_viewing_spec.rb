# frozen_string_literal: true

RSpec.describe "Home page viewing" do
  it "succeeds" do
    visit root_url

    expect(page.status_code).to eq(200)
    expect(page).to have_content "Welcome to Coyote!"
    expect(page).to have_content "Log In"
  end
end
