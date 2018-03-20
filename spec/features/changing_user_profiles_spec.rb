RSpec.describe "Changing one's own user profile" do
  include_context "as a logged-in user"

  it "succeeds" do
    click_link 'Profile'
    expect(current_path).to eq(edit_user_registration_path)

    fill_in 'First name', with: 'Samantha'
    fill_in 'Current password', with: password

    expect {
      click_button 'Update'
      user.reload
    }.to change(user, :first_name).
      to('Samantha')
  end
end
