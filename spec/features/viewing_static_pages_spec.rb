# frozen_string_literal: true

RSpec.describe "Viewing static pages" do
  it "works for the root path" do
    visit root_path
    expect(page).to have_current_path("/")
  end

  it "works for the support page" do
    visit support_path
    expect(page).to have_current_path("/support")
  end

  describe "with a logged-in user" do
    let(:user) { create(:user, :with_membership, password: "password") }

    before { login(user, "password") }

    it "redirects to the user's sole organization at the root path" do
      visit root_path
      expect(page).to have_current_path(organization_path(user.organizations.reload.first))
    end

    it "redirects to the organization selector at the root path if the user has more than one organization" do
      organization = create(:organization)
      user.memberships.create!(organization: organization, role: :editor)
      visit root_path
      expect(page).to have_current_path(organizations_path)
    end
  end
end
