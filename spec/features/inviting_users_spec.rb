require 'nokogiri'

RSpec.feature 'Inviting users' do
  include_context "as a logged-in admin user"

  let(:new_member_email) { 'newmember@example.com' }

  context 'who do already have a Coyote account' do
    let!(:preexisting_user) do
      create(:user,email: new_member_email)
    end

    scenario 'succeeds' do
      visit organization_path(user_organization)
      expect(page.current_path).to eq(organization_path(user_organization))

      click_link 'Invite a user to join'
      expect(page.current_path).to eq(new_organization_invitation_path(user_organization))

      fill_in 'invitation[recipient_email]', with: new_member_email
      select('Editor',from: 'Role')

      expect {
        click_button 'Send invitation'
        expect(page.current_path).to eq(organization_path(user_organization))
      }.to change(user_organization.users,:count).
        from(1).to(2)

      Membership.find_by!(user: preexisting_user,organization: user_organization).tap do |m|
        expect(m).to be_editor
      end

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      ActionMailer::Base.deliveries.first.tap do |email|
        expect(email.to).to eq([new_member_email])
        expect(email.subject).to match(/You are invited to join/i)
      end
    end
  end

  context 'who do not already have a Coyote account' do
    scenario 'succeeds' do
      visit organization_path(user_organization)
      expect(page.current_path).to eq(organization_path(user_organization))

      click_link 'Invite a user to join'
      expect(page.current_path).to eq(new_organization_invitation_path(user_organization))

      fill_in 'invitation[recipient_email]', with: new_member_email
      select('Author',from: 'Role')

      expect {
        click_button 'Send invitation'
        expect(page.current_path).to eq(organization_path(user_organization))
      }.to change(User,:count).
        from(1).to(2)

      new_user = User.find_by!(email: new_member_email)

      Membership.find_by!(user: new_user,organization: user_organization).tap do |m|
        expect(m).to be_author
      end

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      email = ActionMailer::Base.deliveries.first
      expect(email.to).to eq([new_member_email])
      expect(email.subject).to match(/You are invited to join/i)

      html_part = email.parts.find { |p| p.content_type =~ %r{text/html} }
      html_body = Nokogiri::HTML(html_part.body.to_s)

      invite_link = html_body.at_xpath("//a[@id='signup_link']/@href").value
      token = URI(invite_link).query[/=(.+)/,1]
      expect(token).to be_present

      invitation = Invitation.find_by!(token: token)
      expect(invitation).not_to be_redeemed

      visit invite_link
      expect(page.current_url).to eq(invite_link)

      fill_in 'user[email]', with: new_member_email
      fill_in 'user[password]', with: '*' * 10
      fill_in 'user[password_confirmation]', with: '*' * 10

      expect {
        click_button 'Sign up'
        expect(page.current_path).to eq(organization_path(user_organization))
        invitation.reload
      }.to change(invitation,:redeemed?).from(false).to(true)

      expect(invitation).to be_redeemed
    end
  end

  context "who are already members of the organization" do
    let!(:existing_member) do
      create(:user,organization: user_organization,role: 'editor',email: new_member_email)
    end

    scenario 'fails with error message' do
      visit organization_path(user_organization)
      expect(page.current_path).to eq(organization_path(user_organization))

      click_link 'Invite a user to join'
      expect(page.current_path).to eq(new_organization_invitation_path(user_organization))

      fill_in 'invitation[recipient_email]', with: new_member_email
      select('Viewer',from: 'Role')

      expect {
        click_button 'Send invitation'
      }.not_to raise_error

      expect(page.current_path).to eq(organization_invitations_path(user_organization))
      
      Membership.find_by!(user: existing_member,organization: user_organization).tap do |m|
        expect(m).to be_editor
      end

      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end
  end
end

RSpec.feature "Attempting to redeem a previously-redeemed invitation" do
  let!(:redeemed_invitation) do
    create(:invitation,:redeemed)
  end

  scenario 'fails with error message' do
    visit new_registration_path(token: redeemed_invitation.token)
    expect(page.current_path).to eq(new_user_session_path)
  end
end
