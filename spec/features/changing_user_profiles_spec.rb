# frozen_string_literal: true

RSpec.describe "Changing one's own user profile" do
  include_context "with a logged-in user"

  it "succeeds" do
    click_link "Profile"
    expect(page).to have_current_path(edit_user_path, ignore_query: true)

    fill_in "First name", with: "Samantha"
    fill_in "Current password", with: password

    expect {
      click_button "Update"
      user.reload
    }.to change(user, :first_name)
      .to("Samantha")
  end
end
