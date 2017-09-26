RSpec.describe 'Staff usage' do
  include_context 'as a logged-in staff user'

  let!(:editable_user) { create(:user) }
  #let!(:representation) { create(:representation,author: editable_user) }

  scenario 'succeeds' do
    click_first_link 'User Management (Staff)'
    expect(page.current_path).to eq(staff_users_path)

    click_first_link editable_user.email
    expect(page.current_path).to eq(staff_user_path(editable_user))

    click_first_link 'Edit'
    expect(page.current_path).to eq(edit_staff_user_path(editable_user))

    fill_in 'First name', with: 'Wintermute'

    expect {
      click_button 'Save'
      editable_user.reload
    }.to change(editable_user,:first_name).
      to('Wintermute')

    expect(page.current_path).to eq(staff_user_path(editable_user))

    expect {
      click_button 'Send password reset email'
    }.to change(ActionMailer::Base.deliveries,:count).
      from(0).to(1)

    ActionMailer::Base.deliveries.pop.tap do |email|
      expect(email.to).to eq([editable_user.email])
      expect(email.subject).to match(/reset password/i)
    end

    expect(page.current_path).to eq(staff_user_path(editable_user))

    expect {
      click_button 'Delete'
    }.to change { User.exists?(editable_user.id) }.
      from(true).to(false)

    expect(page.current_path).to eq(staff_users_path)

    skip 'need to prevent deleting users who are the authors of representations'

    #expect {
      #click_button 'Delete'
    #}.not_to change { User.exists?(editable_user.id) }

    #expect(page.current_path).to eq(staff_user_path(editable_user))
    #expect(page).to have_content 'Unable to delete'

    #representation.destroy

    #expect {
      #click_button 'Delete'
    #}.to change { User.exists?(editable_user.id) }.
      #from(true).to(false)

    #expect(page.current_path).to eq(staff_user_path(editable_user))
  end
end
