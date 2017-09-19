# == Schema Information
#
# Table name: websites
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  url             :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  strategy        :string
#  organization_id :integer          not null
#
# Indexes
#
#  index_websites_on_organization_id  (organization_id)
#

RSpec.describe WebsitesController do
  let(:organization) { create(:organization) }
  let(:website) { create(:website,organization: organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:website_params) do
    base_params.merge(id: website.id)
  end

  let(:new_website_params) do 
    base_params.merge(website: attributes_for(:website))
  end

  let(:update_website_params) do
    website_params.merge(website: { title: "NEWTITLE" })
  end

  let(:foreign_website) { create(:website) }

  let(:foreign_website_params) do
    { id: foreign_website.id, 
      organization_id: foreign_website.organization_id, 
      website: { title: 'SHOULDNOTBEALLOWED' } }
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: website_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: website_params
        expect(response).to redirect_to(new_user_session_url)

        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: new_website_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_website_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: website_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an editor" do
    include_context "signed-in editor user"

    let!(:website) { create(:website,organization: organization) }

    it "permits read-only actions, forbids create/update/delete" do
      get :index, params: base_params
      expect(response).to be_success

      get :show, params: website_params
      expect(response).to be_success

      expect {
        get :edit, params: website_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :new, params: base_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        post :create, params: new_website_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_website_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: website_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "as an admin" do
    include_context "signed-in admin user"

    it "succeeds for all actions involving organization-owned websites" do
      get :show, params: website_params
      expect(response).to be_success

      get :index, params: base_params
      expect(response).to be_success

      get :edit, params: website_params
      expect(response).to be_success

      get :new, params: base_params
      expect(response).to be_success

      expect {
        post :create, params: new_website_params
        expect(response).to be_redirect
      }.to change(organization.websites,:count).
        by(1)

      post :create, params: base_params.merge(website: { title: '' })
      expect(response).to render_template(:new)

      expect {
        patch :update, params: update_website_params
        website.reload
        expect(response).to be_redirect
      }.to change(website,:title).
        to("NEWTITLE")

      patch :update, params: website_params.merge(website: { title: '' })
      expect(response).to render_template(:edit)
        
      expect {
        delete :destroy, params: website_params
        expect(response).to be_redirect
      }.to change(organization.websites,:size).
        by(-1)

      expect {
        get :edit, params: foreign_website_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        patch :update, params: foreign_website_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        delete :destroy, params: foreign_website_params
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
