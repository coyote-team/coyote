RSpec.describe "Changing organizational memberships" do
  include_context 'as a logged-in admin user'

  let(:member_user) { create(:user) }

  let!(:membership) do
    create(:membership,:viewer,user: member_user,organization: user_organization)
  end

  scenario 'succeeds' do
    click_first_link 'Members'

    within "#membership_#{membership.id}" do
      click_link 'Edit'
    end

    expect(current_path).to eq(edit_organization_membership_path(user_organization,membership))

    select 'Editor', from: 'Role'

    expect {
      click_button 'Save'
    }.to change {
      Coyote::OrganizationUser.new(member_user,user_organization).role
    }.from(:viewer).to(:editor)

    expect(current_path).to eq(organization_memberships_path(user_organization))

    within "#membership_#{membership.id}" do
      expect {
        click_link 'Remove'
      }.to change {
        user_organization.users.exists?(member_user.id)
      }.from(true).to(false)
    end
  end
end
