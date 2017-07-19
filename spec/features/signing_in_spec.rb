feature "Signing in" do
  let(:password) { "abc123PDQ" }
  let!(:user) { create(:user,password: password) }

  scenario "Signing in with correct credentials" do
    visit "/login"

    within(".new_user") do
      fill_in "Email", with: user.email
      fill_in "Password", with: password
    end

    click_button "Log in"

    expect(page.status_code).to eq(200)
    expect(page).to have_content "Welcome to Coyote"
  end

  scenario "Signing in with the wrong password" do
    visit "/login"

    within(".new_user") do
      fill_in "Email", with: user.email
      fill_in "Password", with: "BAD_PASSWORD"
    end

    click_button "Log in"

    expect(page.status_code).to eq(200)
    expect(page).to have_content "Invalid Email or password"
  end
end
