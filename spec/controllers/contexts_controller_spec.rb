RSpec.describe ContextsController do
  let(:organization) { create(:organization) }
  let(:context) { create(:context,organization: organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:context_params) do
    base_params.merge(id: context.id)
  end

  let(:new_context_params) do 
    base_params.merge(context: attributes_for(:context))
  end

  let(:update_context_params) do
    context_params.merge(context: { title: "NEWTITLE" })
  end

  let(:foreign_context) { create(:context) }

  let(:foreign_context_params) do
    { id: foreign_context.id, 
      organization_id: foreign_context.organization_id, 
      context: { title: 'SHOULDNOTBEALLOWED' } }
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: context_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: context_params
        expect(response).to redirect_to(new_user_session_url)

        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: new_context_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_context_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: context_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an editor" do
    include_context "signed-in editor user"

    let!(:context) { create(:context,organization: organization) }

    it "permits read-only actions, forbids create/update/delete" do
      get :index, params: base_params
      expect(response).to be_success

      get :show, params: context_params
      expect(response).to be_success

      expect {
        get :edit, params: context_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :new, params: base_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        post :create, params: new_context_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_context_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: context_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "as an admin" do
    include_context "signed-in admin user"

    it "succeeds for all actions involving organization-owned contexts" do
      get :show, params: context_params
      expect(response).to be_success

      get :index, params: base_params
      expect(response).to be_success

      get :edit, params: context_params
      expect(response).to be_success

      get :new, params: base_params
      expect(response).to be_success

      expect {
        post :create, params: new_context_params
      }.to change(organization.contexts,:count).
        by(1)

      expect {
        patch :update, params: update_context_params
        context.reload
      }.to change(context,:title).
        to("NEWTITLE")

      expect {
        delete :destroy, params: context_params
      }.to change(organization.contexts,:size).
        by(-1)

      expect {
        get :edit, params: foreign_context_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        patch :update, params: foreign_context_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        delete :destroy, params: foreign_context_params
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
