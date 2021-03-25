# frozen_string_literal: true

RSpec.describe "Changing organizational memberships" do
  include_context "with a logged-in admin user"

  let(:member_user) { create(:user) }

  let!(:membership) do
    create(:membership, :viewer, user: member_user, organization: user_organization)
  end

  it "succeeds" do
    click_first_link "Members"

    within "#membership_#{membership.user_id}" do
      click_link member_user.first_name
    end
    click_link "Edit"

    expect(page).to have_current_path(edit_membership_path(membership, organization_id: user_organization), ignore_query: true)

    select "Editor", from: "Role"

    expect {
      click_button "Update Member"
    }.to change {
      Coyote::OrganizationUser.new(member_user, user_organization).role
    }.from(:viewer).to(:editor)

    click_first_link "Members"

    within "#membership_#{membership.user_id}" do
      click_link member_user.first_name
    end

    expect {
      click_link "Delete"
    }.to change {
      user_organization.active_users.exists?(member_user.id)
    }.from(true).to(false)
  end
end
