# frozen_string_literal: true

# == Schema Information
#
# Table name: meta
#
#  id              :integer          not null, primary key
#  name           :string           not null
#  instructions    :text             default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :bigint           not null
#
# Indexes
#
#  index_meta_on_organization_id            (organization_id)
#  index_meta_on_organization_id_and_name  (organization_id,name) UNIQUE
#

RSpec.describe MetaController do
  let(:organization) { create(:organization) }
  let(:metum) { create(:metum, organization: organization) }

  let(:base_params) do
    {organization_id: organization.id}
  end

  let(:metum_params) do
    base_params.merge(id: metum.id)
  end

  let(:new_metum_params) do
    base_params.merge(metum: attributes_for(:metum))
  end

  let(:update_metum_params) do
    metum_params.merge(metum: {name: "NEWNAME"})
  end

  let(:foreign_metum) { create(:metum) }

  let(:foreign_metum_params) do
    {id:              foreign_metum.id,
     organization_id: foreign_metum.organization_id,
     metum:           {name: "SHOULDNOTBEALLOWED"}}
  end

  describe "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: metum_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: metum_params
        expect(response).to redirect_to(new_user_session_url)

        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: new_metum_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_metum_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "as an editor" do
    include_context "signed-in editor user"

    let!(:metum) { create(:metum, organization: organization) }

    it "permits read-only actions, forbids create/update/delete" do
      get :index, params: base_params
      expect(response).to be_successful

      get :show, params: metum_params
      expect(response).to be_successful

      expect {
        get :edit, params: metum_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :new, params: base_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        post :create, params: new_metum_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_metum_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "as an admin" do
    include_context "signed-in admin user"

    it "succeeds for all actions involving organization-owned metums" do
      get :show, params: metum_params
      expect(response).to be_successful

      get :index, params: base_params
      expect(response).to be_successful

      get :edit, params: metum_params
      expect(response).to be_successful

      get :new, params: base_params
      expect(response).to be_successful

      expect {
        post :create, params: new_metum_params
      }.to change(organization.meta, :count)
        .by(1)

      post :create, params: base_params.merge(metum: {name: ""})
      expect(response).to render_template(:new)

      expect {
        patch :update, params: update_metum_params
        metum.reload
      }.to change(metum, :name)
        .to("NEWNAME")

      patch :update, params: metum_params.merge(metum: {name: ""})
      expect(response).to render_template(:edit)

      expect {
        get :edit, params: foreign_metum_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        patch :update, params: foreign_metum_params
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
