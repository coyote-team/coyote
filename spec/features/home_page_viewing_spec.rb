RSpec.feature "Home page viewing" do
  let(:password) { "abc123PDQ" }
  let!(:user) { create(:user,password: password) }

  scenario "succeeds" do
    visit root_url

    expect(page.status_code).to eq(200)
    expect(page).to have_content "Welcome to Coyote!"
    expect(page).to have_content "Log in"
  end
end
