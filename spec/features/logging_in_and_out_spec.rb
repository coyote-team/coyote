feature "Logging in and out" do
  let(:password) { "abc123PDQ" }
  let!(:user) { create(:user,password: password) }

  scenario "Logging in with correct credentials and logging out" do
    login(user,password)
    expect(page.status_code).to eq(200)
    expect(page).to have_content "Signed in successfully"
    logout
    expect(page).to have_content "Signed out successfully"
  end

  scenario "Logging in with the wrong password" do
    login(user,"BAD_PASSWORD")
    expect(page.status_code).to eq(200)
    expect(page).to have_content "Invalid Email or password"
  end
end
