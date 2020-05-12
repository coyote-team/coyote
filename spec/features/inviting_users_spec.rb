# frozen_string_literal: true

require "nokogiri"

RSpec.describe "Inviting users" do
  include_context "as a logged-in admin user"

  let(:new_member_email) { "newmember@example.com" }

  describe "who do already have a Coyote account" do
    let!(:preexisting_user) do
      create(:user, email: new_member_email)
    end

    it "succeeds" do
      visit organization_path(user_organization)
      expect(page).to have_current_path(organization_path(user_organization), ignore_query: true)

      click_link "Invite a user to join"
      expect(page).to have_current_path(new_organization_invitation_path(user_organization), ignore_query: true)

      fill_in "invitation[recipient_email]", with: new_member_email
      select("Editor", from: "Role")

      expect {
        click_button "Send invitation"
        expect(page).to have_current_path(organization_path(user_organization), ignore_query: true)
      }.to change(user_organization.users, :count)
        .from(1).to(2)

      Membership.find_by!(user: preexisting_user, organization: user_organization).tap do |m|
        expect(m).to be_editor
      end

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      ActionMailer::Base.deliveries.first.tap do |email|
        expect(email.to).to eq([new_member_email])
        expect(email.subject).to match(user_organization.name)
      end
    end
  end

  describe "who do not already have a Coyote account" do
    it "succeeds" do
      visit organization_path(user_organization)
      expect(page).to have_current_path(organization_path(user_organization), ignore_query: true)

      click_link "Invite a user to join"
      expect(page).to have_current_path(new_organization_invitation_path(user_organization), ignore_query: true)

      fill_in "invitation[recipient_email]", with: new_member_email
      fill_in "invitation[first_name]", with: "John"
      fill_in "invitation[last_name]", with: "Doe"

      select("Author", from: "Role")

      expect {
        click_button "Send invitation"
        expect(page).to have_current_path(organization_path(user_organization), ignore_query: true)
      }.to change(User, :count)
        .from(1).to(2)

      new_user = User.find_by!(email: new_member_email)

      Membership.find_by!(user: new_user, organization: user_organization).tap do |m|
        expect(m).to be_author
      end

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      email = ActionMailer::Base.deliveries.first
      expect(email.to).to eq([new_member_email])
      expect(email.subject).to match(user_organization.name)

      html_part = email.parts.find { |p| p.content_type =~ %r{text/html} }
      html_body = Nokogiri::HTML(html_part.body.to_s)

      invite_link = html_body.at_xpath("//a[@id='signup_link']/@href").value
      token = URI(invite_link).query[/=(.+)/, 1]
      expect(token).to be_present

      invitation = Invitation.find_by!(token: token)
      expect(invitation).not_to be_redeemed

      visit invite_link
      expect(page.current_url).to eq(invite_link)

      fill_in "user[email]", with: new_member_email
      fill_in "user[password]", with: "*" * 10
      fill_in "user[password_confirmation]", with: "*" * 10

      expect {
        click_button "Sign up"
        expect(page).to have_current_path(organization_path(user_organization), ignore_query: true)
        invitation.reload
      }.to change(invitation, :redeemed?).from(false).to(true)

      expect(invitation).to be_redeemed
    end
  end

  describe "who are already members of the organization" do
    let!(:existing_member) do
      create(:user, organization: user_organization, role: "editor", email: new_member_email)
    end

    it "fails with error message" do
      visit organization_path(user_organization)
      expect(page).to have_current_path(organization_path(user_organization), ignore_query: true)

      click_link "Invite a user to join"
      expect(page).to have_current_path(new_organization_invitation_path(user_organization), ignore_query: true)

      fill_in "invitation[recipient_email]", with: new_member_email
      select("Viewer", from: "Role")

      expect {
        click_button "Send invitation"
      }.not_to raise_error

      expect(page).to have_current_path(organization_invitations_path(user_organization), ignore_query: true)

      Membership.find_by!(user: existing_member, organization: user_organization).tap do |m|
        expect(m).to be_editor
      end

      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end
  end
end

RSpec.describe "Attempting to redeem a previously-redeemed invitation" do
  let!(:redeemed_invitation) do
    create(:invitation, :redeemed)
  end

  it "fails with error message" do
    visit new_registration_path(token: redeemed_invitation.token)
    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
  end
end
