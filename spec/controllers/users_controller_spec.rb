# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  authentication_token   :string           not null
#  staff                  :boolean          default(FALSE), not null
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  organizations_count    :integer          default(0)
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#

RSpec.describe UsersController do
  let(:organization) { create(:organization) }
  let(:user_of_interest) { create(:user,organization: organization) }

  let(:base_params) do
    { id: user_of_interest.id }
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :show, params: base_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as a guest user" do
    include_context "signed-in guest user"

    it "succeeds for critical actions" do
      get :show, params: base_params
      expect(response).to be_success
    end
  end
end
