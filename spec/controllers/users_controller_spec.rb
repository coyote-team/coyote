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
#  authentication_token   :string
#  staff                  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

RSpec.describe UsersController do
  let(:organization) { create(:organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:user_params) do
    base_params.merge(id: user.id)
  end

  let(:other_user) { create(:user) }

  let(:update_user_params) do
    user_params.merge(user: { first_name: "NEWNAME" })
  end

  let(:other_user) { create(:user,organization: organization) }

  let(:other_user_params) do
    base_params.merge(id: other_user.id)
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: base_params.merge(id: other_user.id)
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: base_params.merge(id: other_user.id)
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: base_params.merge(id: other_user.id,user: {})
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: base_params.merge(id: other_user.id)
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as a staff user" do
    include_context "signed-in staff user"

    it "succeeds for critical actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to be_success

        get :show, params: base_params.merge(id: user.id)
        expect(response).to be_success

        get :edit, params: base_params.merge(id: user.id)
        expect(response).to be_success

        expect {
          patch :update, params: base_params.merge(id: user.id,user: { first_name: "NEWNAME" })
          expect(response).to redirect_to([organization,user])
          user.reload
        }.to change(user,:first_name).to("NEWNAME")

        expect {
          delete :destroy, params: base_params.merge(id: user.id)
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  context "as a staff member" do
    include_context "signed-in staff user"

    it "succeeds for basic actions" do
      aggregate_failures do
        get :edit, params: base_params.merge(id: other_user.id)
        expect(response).to be_success

        expect {
          patch :update, params: base_params.merge(id: other_user.id,user: { first_name: "NEWNAME" })
          expect(response).to redirect_to([organization,other_user])
          other_user.reload
        }.to change(other_user,:first_name).to("NEWNAME")

        expect {
          delete :destroy, params: base_params.merge(id: other_user.id)
          expect(response).to redirect_to(organization_users_url(organization))
        }.to change { 
          User.exists?(other_user.id)
        }.from(true).to(false)

        expect {
          delete :destroy, params: base_params.merge(id: user.id)
        }.to raise_error(Pundit::NotAuthorizedError) # can't destroy own user record
      end
    end
  end
end
