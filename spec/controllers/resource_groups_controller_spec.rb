# == Schema Information
#
# Table name: resource_groups
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_title  (organization_id,title) UNIQUE
#

RSpec.describe ResourceGroupsController do
  let(:organization) { create(:organization) }
  let(:resource_group) { create(:resource_group,organization: organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:resource_group_params) do
    base_params.merge(id: resource_group.id)
  end

  let(:new_resource_group_params) do 
    base_params.merge(resource_group: attributes_for(:resource_group))
  end

  let(:update_resource_group_params) do
    resource_group_params.merge(resource_group: { title: "NEWTITLE" })
  end

  let(:foreign_resource_group) { create(:resource_group) }

  let(:foreign_resource_group_params) do
    { id: foreign_resource_group.id, 
      organization_id: foreign_resource_group.organization_id, 
      resource_group: { title: 'SHOULDNOTBEALLOWED' } }
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: resource_group_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: resource_group_params
        expect(response).to redirect_to(new_user_session_url)

        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: new_resource_group_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_resource_group_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: resource_group_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an editor" do
    include_context "signed-in editor user"

    let!(:resource_group) { create(:resource_group,organization: organization) }

    it "permits read-only actions, forbids create/update/delete" do
      get :index, params: base_params
      expect(response).to be_success

      get :show, params: resource_group_params
      expect(response).to be_success

      expect {
        get :edit, params: resource_group_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :new, params: base_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        post :create, params: new_resource_group_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_resource_group_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: resource_group_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "as an admin" do
    include_context "signed-in admin user"

    it "succeeds for all actions involving organization-owned resource_groups" do
      get :show, params: resource_group_params
      expect(response).to be_success

      get :index, params: base_params
      expect(response).to be_success

      get :edit, params: resource_group_params
      expect(response).to be_success

      get :new, params: base_params
      expect(response).to be_success

      expect {
        post :create, params: new_resource_group_params
      }.to change(organization.resource_groups,:count).
        by(1)

      expect {
        patch :update, params: update_resource_group_params
        resource_group.reload
      }.to change(resource_group,:title).
        to("NEWTITLE")

      expect {
        delete :destroy, params: resource_group_params
      }.to change(organization.resource_groups,:size).
        by(-1)

      expect {
        get :edit, params: foreign_resource_group_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        patch :update, params: foreign_resource_group_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        delete :destroy, params: foreign_resource_group_params
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
