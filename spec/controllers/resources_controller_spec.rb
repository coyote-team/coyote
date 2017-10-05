# == Schema Information
#
# Table name: resources
#
#  id              :integer          not null, primary key
#  identifier      :string           not null
#  title           :string           default("Unknown"), not null
#  resource_type   :enum             not null
#  canonical_id    :string           not null
#  source_uri      :string
#  context_id      :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_resources_on_context_id                        (context_id)
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#

RSpec.describe ResourcesController do
  let(:organization) { create(:organization) }
  let(:context) { create(:context,organization: organization) }
  let(:resource) { create(:resource,organization: organization) }  

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:resource_params) do
    base_params.merge(id: resource.id)
  end

  let(:new_resource_params) do
    resource = attributes_for(:resource,organization: organization)
    resource[:context_id] = context.id
    base_params.merge(resource: resource)
  end

  let(:update_resource_params) do
    resource_params.merge(resource: { title: "NEWTITLE" })
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: resource_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: resource_params
        expect(response).to redirect_to(new_user_session_url)

        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: new_resource_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_resource_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: update_resource_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an author" do
    include_context "signed-in author user"

    it "succeeds for basic actions" do
      get :show, params: resource_params
      expect(response).to be_success

      get :index, params: base_params
      expect(response).to be_success

      expect {
        get :edit, params: resource_params
      }.to raise_error(Pundit::NotAuthorizedError)

      get :new, params: base_params
      expect(response).to be_success

      expect {
        post :create, params: new_resource_params
        expect(response).to be_redirect
      }.to change(organization.resources,:count).by(1)

      post :create, params: base_params.merge(resource: { context_id: nil })
      expect(response).not_to be_redirect
      
      expect {
        patch :update, params: update_resource_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: update_resource_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "as an editor" do
    include_context "signed-in editor user"

    it "succeeds for critical actions" do
      get :new, params: base_params
      expect(response).to be_success

      get :edit, params: resource_params
      expect(response).to be_success

      expect {
        patch :update, params: update_resource_params
        expect(response).to redirect_to([organization,resource])
        resource.reload
      }.to change(resource,:title).to("NEWTITLE")

      post :update, params: update_resource_params.merge(resource: { resource_type: '' })
      expect(response).not_to be_redirect

      expect {
        delete :destroy, params: update_resource_params
        expect(response).to redirect_to(organization_resources_url(organization))
      }.to change { Resource.exists?(resource.id) }.
        from(true).to(false)
    end
  end
end
