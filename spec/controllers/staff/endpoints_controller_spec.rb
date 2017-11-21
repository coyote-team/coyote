RSpec.describe Staff::EndpointsController do
  let(:editable_endpoint) { create(:endpoint) }
  let(:organization) { create(:organization) }

  let(:endpoint_params) do
    { id: editable_endpoint.id }
  end

  let(:create_endpoint_params) do
    { endpoint: { name: 'ABC123' } }
  end

  let(:update_endpoint_params) do
    endpoint_params.merge(endpoint: { name: 'XYZ' })
  end

  context "as a signed-out endpoint" do
    include_context 'signed-out user'

    it "requires login for all actions" do
      aggregate_failures do
        get :index
        expect(response).to redirect_to(new_user_session_url)

        get :new
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: endpoint_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: endpoint_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: create_endpoint_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_endpoint_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: endpoint_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as a signed-in owner" do
    include_context 'signed-in owner user'

    it "requires endpoint to be a staff member for all actions" do
      aggregate_failures do
        expect {
          get :new
        }.to raise_error(Coyote::SecurityError)

        expect {
          get :index
        }.to raise_error(Coyote::SecurityError)

        expect {
          get :show, params: endpoint_params
        }.to raise_error(Coyote::SecurityError)

        expect {
          get :edit, params: endpoint_params
        }.to raise_error(Coyote::SecurityError)

        expect {
          patch :update, params: update_endpoint_params
        }.to raise_error(Coyote::SecurityError)

        expect {
          post :create, params: create_endpoint_params
        }.to raise_error(Coyote::SecurityError)

        expect {
          delete :destroy, params: endpoint_params
        }.to raise_error(Coyote::SecurityError)
      end
    end
  end

  context "as a staff member" do
    include_context 'signed-in staff user'

    it "succeeds for all actions involving organization-owned contexts" do
      get :new
      expect(response).to be_success

      post :create, params: create_endpoint_params
      expect(response).to be_redirect

      get :show, params: endpoint_params
      expect(response).to be_success

      get :index
      expect(response).to be_success

      get :edit, params: endpoint_params
      expect(response).to be_success

      expect {
        patch :update, params: update_endpoint_params
        editable_endpoint.reload
      }.to change(editable_endpoint,:name).
        to('XYZ')

      expect(response).to be_redirect

      patch :update, params: endpoint_params.merge(endpoint: { name: '' })
      expect(response).not_to be_redirect
        
      expect {
        delete :destroy, params: endpoint_params
      }.to change { Endpoint.exists?(editable_endpoint.id) }.
        from(true).to(false)
    end
  end
end
