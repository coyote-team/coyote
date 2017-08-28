RSpec.feature "New user signing-up" do
  scenario "succeeds" do
    visit new_user_registration_path

    fill_in "user[first_name]",              with: "Janie"
    fill_in "user[last_name]",               with: "Davis"
    fill_in "user[email]",                   with: "janie@example.com"
    fill_in "user[password]",                with: "12345678"
    fill_in "user[password_confirmation]",   with: "12345678"

    expect {
      click_button "Sign up"
    }.to change(User,:count).
      from(0).to(1)

    expect(current_path).to eq(root_path)
    expect(page).to have_content("Janie Davis")
  end
end
