RSpec.describe ResourceLinksController do
  let(:organization) { create(:organization) }
  let(:subject_resource) { create(:resource,organization: organization) }
  let(:object_resource) { create(:resource,organization: organization) }
  let(:resource_link) do 
    create(:resource_link,verb: 'hasPart',subject_resource: subject_resource,object_resource: object_resource)
  end

  let(:resource_link_params) do
    { id: resource_link.id }
  end

  let(:new_resource_link_params) do
    { 
      resource_link: { 
        subject_resource_id: subject_resource.id,
        verb: 'isVersionOf',
        object_resource_id: object_resource.id 
      }
    }
  end

  let(:update_resource_link_params) do
    resource_link_params.merge(resource_link: { verb: 'hasFormat' })
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :show, params: resource_link_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: resource_link_params
        expect(response).to redirect_to(new_user_session_url)

        get :new
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: new_resource_link_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_resource_link_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: resource_link_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an author" do
    include_context "signed-in author user"

    it "succeeds for basic actions" do
      get :show, params: resource_link_params
      expect(response).to be_success

      expect {
        get :edit, params: resource_link_params
      }.to raise_error(Pundit::NotAuthorizedError)

      get :new, params: { subject_resource_id: subject_resource.id }
      expect(response).to be_success

      expect {
        post :create, params: new_resource_link_params
        expect(response).to be_redirect
      }.to change(subject_resource.subject_resource_links,:count).by(1)

      expect {
        patch :update, params: update_resource_link_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: update_resource_link_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "as an editor" do
    include_context "signed-in editor user"

    it "succeeds for critical actions" do
      get :new, params: { subject_resource_id: subject_resource.id }
      expect(response).to be_success

      get :edit, params: resource_link_params
      expect(response).to be_success

      expect {
        patch :update, params: update_resource_link_params
        expect(response).to redirect_to(resource_link)
        resource_link.reload
      }.to change(resource_link,:verb).to('hasFormat')

      expect {
        delete :destroy, params: resource_link_params
        expect(response).to redirect_to([organization,subject_resource])
      }.to change { ResourceLink.exists?(resource_link.id) }.
        from(true).to(false)
    end
  end
end
