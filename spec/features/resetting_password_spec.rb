RSpec.feature "Resetting a password" do
  let(:user) { create(:user) }

  scenario "succeeds" do
    visit new_user_password_path

    fill_in "user[email]", with: user.email

    expect {
      click_button "Send me reset password instructions"
    }.to change(ActionMailer::Base.deliveries,:count).
      from(0).to(1)

    ActionMailer::Base.deliveries.first.tap do |email|
      expect(email.to).to eq([user.email])
      expect(email.subject).to match(/reset password/i)

      skip "need to check clicking the link here"
    end
  end
end
