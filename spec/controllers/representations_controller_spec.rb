# frozen_string_literal: true

# == Schema Information
#
# Table name: representations
#
#  id           :bigint           not null, primary key
#  resource_id  :bigint           not null
#  text         :text
#  content_uri  :string
#  status       :enum             default("ready_to_review"), not null
#  metum_id     :bigint           not null
#  author_id    :bigint           not null
#  content_type :string           default("text/plain"), not null
#  language     :string           not null
#  license_id   :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  notes        :text
#  ordinality   :integer
#
# Indexes
#
#  index_representations_on_author_id    (author_id)
#  index_representations_on_license_id   (license_id)
#  index_representations_on_metum_id     (metum_id)
#  index_representations_on_resource_id  (resource_id)
#  index_representations_on_status       (status)
#

RSpec.describe RepresentationsController do
  let(:organization) { create(:organization) }
  let(:metum) { create(:metum) }
  let(:license) { create(:license) }
  let(:resource) { create(:resource, organization: organization) }

  let(:base_params) do
    {organization_id: organization}
  end

  let(:representation_params) do
    base_params.merge(id: representation.id)
  end

  let(:new_representation_params) do
    base_params.merge({
      representation: attributes_for(
        :representation,
        author_id:  user.id,
        license_id: license.id,
        metum_id:   metum.id,
      ),
      resource_id:    resource.id,
    })
  end

  let(:update_representation_params) do
    representation_params.merge(representation: {text: "NEWTEXT"})
  end

  let(:representation) do
    create(:representation, organization: organization)
  end

  describe "as a signed-out user" do
    include_context "with no user signed in"

    let(:user) { build_stubbed(:user) }

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to require_login

        get :show, params: representation_params
        expect(response).to require_login

        get :edit, params: representation_params
        expect(response).to require_login

        get :new, params: base_params
        expect(response).to require_login

        post :create, params: new_representation_params
        expect(response).to require_login

        patch :update, params: update_representation_params
        expect(response).to require_login

        delete :destroy, params: update_representation_params
        expect(response).to require_login
      end
    end
  end

  describe "as a viewer user" do
    include_context "with a signed-in viewer user"

    it "succeeds for view-only actions, fails for edit actions" do
      get :index, params: base_params
      expect(response).to be_successful

      get :show, params: representation_params
      expect(response).to be_successful

      expect {
        get :edit, params: representation_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :new, params: new_representation_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        post :create, params: new_representation_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_representation_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: update_representation_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "as an author working with his or her own content" do
    include_context "with a signed-in author user"

    let(:representation) do
      create(:representation, author: user, organization: organization, resource: resource)
    end

    before do
      create(:assignment, resource: resource, user: user)
    end

    it "succeeds for basic actions" do
      get :edit, params: representation_params
      expect(response).to be_successful

      get :new, params: new_representation_params
      expect(response).to be_successful

      expect {
        post :create, params: new_representation_params
        expect(response).to be_redirect
        resource.reload
      }.to change(resource.representations, :count)
        .from(1).to(2)

      post :create, params: base_params.merge(representation: {metum_id: metum.id}, resource_id: resource.id)
      expect(response).not_to be_redirect

      expect {
        patch :update, params: update_representation_params
        representation.reload
      }.to change(representation, :text)
        .to("NEWTEXT")

      expect(response).to redirect_to(representation_path(representation, organization_id: organization))

      patch :update, params: representation_params.merge(representation: {license_id: nil})
      expect(response).not_to be_redirect

      expect {
        delete :destroy, params: update_representation_params
      }.to change { Representation.exists?(representation.id) }
        .from(true).to(false)

      expect(response).to redirect_to(representations_path(organization_id: organization))
    end
  end

  describe "as an author working with another author's content" do
    include_context "with a signed-in author user"

    let(:other_author) do
      create(:user, organization: organization)
    end

    let(:representation) do
      create(:representation, author: other_author, organization: organization)
    end

    it "fails for all actions" do
      expect {
        post :create, params: new_representation_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :new, params: new_representation_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :edit, params: representation_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_representation_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: update_representation_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
