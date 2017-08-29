require 'nokogiri'

RSpec.feature 'Resetting a password' do
  let(:user) { create(:user,:with_membership) }

  scenario 'succeeds' do
    visit new_user_password_path

    fill_in 'user[email]', with: user.email

    expect {
      click_button 'Send me reset password instructions'
    }.to change(ActionMailer::Base.deliveries,:count).
      from(0).to(1)

    ActionMailer::Base.deliveries.pop.tap do |email|
      expect(email.to).to eq([user.email])
      expect(email.subject).to match(/reset password/i)

      email_body = email.body.to_s
      email_dom = Nokogiri::HTML(email_body)

      reset_link = email_dom.at_xpath('//a/@href').value
      expect(reset_link).to be_present

      visit reset_link
      expect(current_path).to eq(edit_user_password_path)

      new_password = 'abcdefgh'

      fill_in 'New password', with: new_password
      fill_in 'Confirm new password', with: new_password

      click_button 'Change my password'
      expect(page).to have_content('Your password has been changed')

      login(user,new_password)
    end
  end
end
