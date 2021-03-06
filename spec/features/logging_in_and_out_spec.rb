# frozen_string_literal: true

RSpec.describe "Logging in and out" do
  let(:password) { "abc123PDQ" }

  let!(:organization) { create(:organization) }

  let!(:user) do
    create(:user, organization: organization, password: password)
  end

  let(:resource) do
    create(:resource, organization: organization)
  end

  it "Logging in with correct credentials and logging out" do
    visit resource_path(resource, organization_id: organization)
    expect(page.status_code).to eq(200)
    expect(page).to have_current_path(new_session_path, ignore_query: true)

    login(user, password)

    expect(page.status_code).to eq(200)
    expect(page).to have_content "Signed in successfully"
    expect(page).to have_current_path(resource_path(resource, organization_id: organization), ignore_query: true)

    logout

    expect(page).to have_content "Signed out successfully"
    visit resources_path(organization_id: user.organizations.first)
    expect(page).to have_current_path(new_session_path, ignore_query: true)
  end

  it "Logging in with the wrong password" do
    login(user, "BAD_PASSWORD", false)
    expect(page.status_code).to eq(200)
    expect(page).to have_content "Invalid email or password"
  end
end
