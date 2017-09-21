RSpec.feature 'Locking and unlocking an account' do
  let(:password) { 'ABC12345' }
  let(:user) { create(:user,password: password) }

  scenario 'succeeds' do
    visit login_path

    expect {
      Rails.application.config.x.maximum_login_attempts.times do
        within('.new_user') do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: 'XYZPDQ987'
        end

        click_button 'Log in'
        expect(page.current_path).to eq(new_user_session_path)
      end

      user.reload
    }.to change(user,:access_locked?).
      from(false).to(true)

    expect(ActionMailer::Base.deliveries.size).to eq(1)

    ActionMailer::Base.deliveries.pop.tap do |email|
      expect(email.to).to eq([user.email])
      expect(email.subject).to match(/unlock instructions/i)

      unlock_link = extract_email_link(email)
      expect(unlock_link).to be_present

      expect {
        visit unlock_link
        user.reload
      }.to change(user,:access_locked?).
        from(true).to(false)

      expect(current_path).to eq(new_user_session_path)

      login(user,password,true)
    end
  end
end
