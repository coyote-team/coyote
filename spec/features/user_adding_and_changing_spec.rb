# frozen_string_literal: true

RSpec.describe "User adding and changing" do
  include_context "with a logged-in staff user"

  let!(:editable_user) { create(:user) }

  it "succeeds" do
    click_first_link "User Management (Staff)"
    expect(page).to have_current_path(staff_users_path, ignore_query: true)

    click_first_link editable_user.email
    expect(page).to have_current_path(staff_user_path(editable_user), ignore_query: true)

    click_first_link "Edit"
    expect(page).to have_current_path(edit_staff_user_path(editable_user), ignore_query: true)

    fill_in "First name", with: "Wintermute"

    expect {
      click_button "Update User"
      editable_user.reload
    }.to change(editable_user, :first_name)
      .to("Wintermute")

    expect(page).to have_current_path(staff_user_path(editable_user), ignore_query: true)

    expect {
      click_button "Send password reset email"
    }.to change(ActionMailer::Base.deliveries, :count)
      .from(0).to(1)

    ActionMailer::Base.deliveries.pop.tap do |email|
      expect(email.to).to eq([editable_user.email])
      expect(email.subject).to match("Reset your Coyote password")
    end

    expect(page).to have_current_path(staff_user_path(editable_user), ignore_query: true)

    expect {
      click_link "Archive"
      editable_user.reload
    }.to(change(editable_user, :active?))

    expect(page).to have_current_path(staff_users_path, ignore_query: true)
  end
end
