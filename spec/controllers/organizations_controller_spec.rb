# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_on_name  (name) UNIQUE
#

RSpec.describe OrganizationsController do
  let(:organization) { create(:organization) }

  let(:existing_organization_params) do
    {id: organization.id}
  end

  let(:new_organization_params) do
    {organization: attributes_for(:organization)}
  end

  let(:update_organization_params) do
    {organization: {name: "NEWNAME"}}
  end

  describe "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: {id: 1}
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: {id: 1}
        expect(response).to redirect_to(new_user_session_url)

        get :new
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: new_organization_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_organization_params.merge(id: 1)
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "as an admin" do
    include_context "signed-in guest user"

    it "succeeds for basic actions" do
      get :index
      expect(response).to be_successful

      get :show, params: existing_organization_params
      expect(response).to be_successful

      expect {
        get :edit, params: existing_organization_params
      }.to raise_error(Pundit::NotAuthorizedError)

      get :new
      expect(response).to be_successful

      expect {
        post :create, params: new_organization_params
        expect(response).to be_redirect
      }.to change {
        user.memberships.owner.where.not(organization: organization).count
      }.from(0).to(1)

      post :create, params: {organization: {name: ""}}
      expect(response).not_to be_redirect

      expect {
        patch :update, params: existing_organization_params.merge(update_organization_params)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "as an organization ower" do
    include_context "signed-in owner user"

    it "succeeds for critical actions" do
      get :edit, params: existing_organization_params
      expect(response).to be_successful

      expect {
        patch :update, params: existing_organization_params.merge(update_organization_params)
        organization.reload
      }.to change(organization, :name).to("NEWNAME")

      patch :update, params: existing_organization_params.merge(organization: {name: ""})
      expect(response).not_to be_redirect
    end
  end
end
