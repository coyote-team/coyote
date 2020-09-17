# frozen_string_literal: true

require "nokogiri"

RSpec.describe "Resetting a password" do
  let(:user) { create(:user, :with_membership) }

  it "succeeds" do
    visit new_password_reset_path

    fill_in "user[email]", with: user.email

    expect {
      click_button "Send me reset password instructions"
    }.to change(ActionMailer::Base.deliveries, :count)
      .from(0).to(1)

    ActionMailer::Base.deliveries.pop.tap do |email|
      expect(email.to).to eq([user.email])
      expect(email.subject).to eq("Reset your Coyote password")

      reset_link = extract_email_link(email)
      expect(reset_link).to be_present

      visit URI.parse(reset_link).path
      expect(page).to have_current_path(password_reset_path(user.password_resets.first.token), ignore_query: true)

      new_password = "abcdefgh"

      fill_in "New password", with: new_password
      fill_in "Confirm new password", with: new_password

      click_button "Change my password"
      expect(page).to have_content("Your password has been changed")

      expect(user.reload.authenticate(new_password)).to eq(user)
    end
  end
end
