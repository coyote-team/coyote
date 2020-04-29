# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  organization_id :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role            :enum             default("guest"), not null
#  active          :boolean          default(TRUE)
#
# Indexes
#
#  index_memberships_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#

# rubocop:disable Metrics/BlockLength

RSpec.describe MembershipsController do
  let(:organization) { create(:organization) }
  let(:membership) { create(:membership, organization: organization) }

  let(:base_params) do
    {organization_id: organization.id}
  end

  let(:membership_params) do
    base_params.merge(id: membership.id)
  end

  let(:update_membership_params) do
    membership_params.merge(membership: {role: "editor"})
  end

  let(:foreign_membership) { create(:membership) }

  let(:foreign_membership_params) do
    {id:              foreign_membership.id,
     organization_id: foreign_membership.organization_id,
     membership:      {role: "editor"}}
  end

  let(:own_membership_params) do
    base_params.merge(id: user_membership.id)
  end

  describe "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: membership_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_membership_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: membership_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "as an editor" do
    include_context "signed-in editor user"

    it "permits read-only actions, forbids updating and deleting other memberships, does allow deleting one's own membership" do
      get :index, params: base_params
      expect(response).to be_successful

      expect {
        get :edit, params: membership_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_membership_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: membership_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: base_params.merge(id: user_membership.id)
        expect(response).to be_redirect
      }.to change { Membership.active.exists?(user_membership.id) }
        .from(true).to(false)
    end
  end

  describe "as an admin" do
    include_context "signed-in admin user"

    it "succeeds for all actions involving organization-owned memberships" do
      get :index, params: base_params
      expect(response).to be_successful

      get :edit, params: membership_params
      expect(response).to be_successful

      expect {
        patch :update, params: update_membership_params
        membership.reload
        expect(response).to be_redirect
      }.to change(membership, :role)
        .from("guest").to("editor")

      patch :update, params: membership_params.merge(membership: {role: ""})
      expect(response).not_to be_redirect

      expect {
        delete :destroy, params: membership_params
        expect(response).to be_redirect
      }.to change(organization.active_users, :count)
        .by(-1)

      expect {
        get :edit, params: foreign_membership_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        patch :update, params: foreign_membership_params
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        delete :destroy, params: foreign_membership_params
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "as an admin attempting to change his or her own role" do
    include_context "signed-in admin user"

    let(:own_membership_update_params) do
      own_membership_params.merge({
        membership: {role: "owner"},
      })
    end

    it "fails for edit and update actions, succeeds for delete" do
      expect {
        get :edit, params: own_membership_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: own_membership_update_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: own_membership_params
        expect(response).to be_redirect
      }.to change { Membership.active.exists?(user_membership.id) }
        .from(true).to(false)
    end
  end

  describe "as an admin attempting to grant an owner role to another user" do
    include_context "signed-in admin user"

    let(:update_membership_params) do
      membership_params.merge(membership: {role: "owner"})
    end

    it "fails" do
      expect {
        patch :update, params: update_membership_params
      }.to raise_error(Coyote::SecurityError)

      membership.reload
      expect(membership.role).to eq("guest")
    end
  end

  describe "as the last owner of an organization" do
    include_context "signed-in owner user"

    it "cannot remove self from the organization until another owner is created" do
      expect {
        delete :destroy, params: own_membership_params
        expect(response).to be_redirect
      }.not_to change { Membership.active.exists?(user_membership.id) }
        .from(true)

      expect(flash[:alert]).to be_present
    end
  end
end

# rubocop:enable Metrics/BlockLength
