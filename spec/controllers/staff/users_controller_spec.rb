RSpec.describe Staff::UsersController do
  let(:editable_user) { create(:user) }
  let(:organization) { create(:organization) }

  let(:user_params) do
    { id: editable_user.id }
  end

  let(:update_user_params) do
    user_params.merge(user: { first_name: 'XYZ' })
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: user_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: user_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_user_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: user_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as a signed-in owner" do
    include_context "signed-in owner user"

    it "requires user to be a staff member for all actions" do
      aggregate_failures do
        expect {
          get :index
        }.to raise_error(Coyote::SecurityError)

        expect {
          get :show, params: user_params
        }.to raise_error(Coyote::SecurityError)

        expect {
          get :edit, params: user_params
        }.to raise_error(Coyote::SecurityError)

        expect {
          patch :update, params: update_user_params
        }.to raise_error(Coyote::SecurityError)

        expect {
          delete :destroy, params: user_params
        }.to raise_error(Coyote::SecurityError)
      end
    end
  end

  context "as a staff member" do
    include_context "signed-in staff user"

    it "succeeds for all actions involving organization-owned contexts" do
      get :show, params: user_params
      expect(response).to be_success

      get :index
      expect(response).to be_success

      get :edit, params: user_params
      expect(response).to be_success

      expect {
        patch :update, params: update_user_params
        editable_user.reload
      }.to change(editable_user,:first_name).
        to('XYZ')

      expect {
        delete :destroy, params: user_params
      }.to change { User.exists?(editable_user.id) }.
        from(true).to(false)
    end
  end
end
