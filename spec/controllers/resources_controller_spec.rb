# frozen_string_literal: true

RSpec.describe ResourcesController do
  let(:organization) { create(:organization) }
  let(:resource_group) { create(:resource_group, organization: organization) }
  let(:resource) { create(:resource, canonical_id: "test-resource", organization: organization) }

  let(:base_params) do
    {organization_id: organization}
  end

  let(:resource_params) do
    base_params.merge(id: resource.id)
  end

  let(:new_resource_params) do
    resource = attributes_for(:resource, organization: organization)
    resource[:resource_group_id] = resource_group.id
    base_params.merge(resource: resource)
  end

  let(:update_resource_params) do
    resource_params.merge(resource: {name: "NEWNAME"})
  end

  describe "as a signed-out user" do
    include_context "with no user signed in"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to require_login

        get :show, params: resource_params
        expect(response).to require_login

        get :edit, params: resource_params
        expect(response).to require_login

        get :new, params: base_params
        expect(response).to require_login

        post :create, params: new_resource_params
        expect(response).to require_login

        patch :update, params: update_resource_params
        expect(response).to require_login

        delete :destroy, params: update_resource_params
        expect(response).to require_login
      end
    end
  end

  describe "as an author" do
    include_context "with a signed-in author user"

    it "shows resources" do
      get :show, params: resource_params
      expect(response).to be_successful
    end

    it "shows resources by canonical_id" do
      get :show, params: base_params.merge(canonical_id: resource.canonical_id)
      expect(response).to redirect_to(resource_path(resource.id))
    end

    it "lists resources" do
      get :index, params: base_params
      expect(response).to be_successful
    end

    it "does not allow creating, editing, or deleting" do
      expect {
        get :new, params: base_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        post :create, params: new_resource_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :edit, params: resource_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_resource_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: update_resource_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "as an editor" do
    include_context "with a signed-in editor user"

    it "succeeds for critical actions" do
      get :new, params: base_params
      expect(response).to be_successful

      expect {
        post :create, params: new_resource_params
      }.to change(organization.resources, :count).by(1)

      post :create, params: base_params.merge(resource: {resource_group_id: nil})
      expect(response).not_to be_redirect

      get :edit, params: resource_params
      expect(response).to be_successful

      expect {
        patch :update, params: update_resource_params
        expect(response).to redirect_to(resource)
        resource.reload
      }.to change(resource, :name).to("NEWNAME")

      post :update, params: update_resource_params.merge(resource: {resource_type: ""})
      expect(response).not_to be_redirect

      expect {
        delete :destroy, params: update_resource_params
        expect(response).to redirect_to(resources_path(organization_id: organization))
      }.to change { resource.reload.is_deleted? }
        .from(false).to(true)
    end
  end
end
