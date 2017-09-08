# == Schema Information
#
# Table name: descriptions
#
#  id         :integer          not null, primary key
#  locale     :string           default("en")
#  text       :text
#  status_id  :integer          not null
#  image_id   :integer          not null
#  metum_id   :integer          not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  license    :string           default("cc0-1.0")
#
# Indexes
#
#  index_descriptions_on_image_id   (image_id)
#  index_descriptions_on_metum_id   (metum_id)
#  index_descriptions_on_status_id  (status_id)
#  index_descriptions_on_user_id    (user_id)
#

RSpec.describe DescriptionsController do
  let(:organization) { create(:organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:description_params) do
    base_params.merge(id: description.id)
  end

  let(:image) { create(:image,organization: organization) }
  let(:status) { create(:status) }
  let(:metum) { create(:metum) }

  let(:update_description_params) do
    description_params.merge(description: { text: "NEWTEXT" })
  end

  let(:description) { create(:description,image: image) }

  let(:other_description) { create(:description,image: image) }

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: description_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: description_params
        expect(response).to redirect_to(new_user_session_url)

        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: base_params.merge(description: {})
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_description_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: update_description_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an author" do
    include_context "signed-in author user"

    let(:description) do 
      create(:description,user: user,image: image)
    end

    let(:new_description_params) do
      attribs = attributes_for(:description)

      attribs.merge!({
        image_id: image.id,
        status_id: status.id,
        metum_id: metum.id,
        user_id: user.id
      })

      base_params.merge(description: attribs)
    end

    it "succeeds for basic actions" do
      get :index, params: base_params
      expect(response).to be_success

      get :show, params: description_params
      expect(response).to be_success

      get :edit, params: description_params
      expect(response).to be_success

      expect {
        get :edit, params: base_params.merge(id: other_description.id)
      }.to raise_error(Pundit::NotAuthorizedError)

      get :new, params: base_params
      expect(response).to be_success

      expect {
        post :create, params: new_description_params
        expect(response).to be_redirect
      }.to change(user.descriptions,:count).by(1)

      expect {
        patch :update, params: update_description_params
        expect(response).to redirect_to([organization,description])
        description.reload
      }.to change(description,:text).to("NEWTEXT")

      expect {
        patch :update, params: update_description_params.merge(id: other_description.id)
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: description_params
        expect(response).to redirect_to(organization_descriptions_url(organization))
      }.to change { Description.exists?(description.id) }.
        from(true).to(false)

      expect {
        delete :destroy, params: base_params.merge(id: other_description.id)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "as an editor" do
    include_context "signed-in editor user"

    let(:description) do 
      create(:description,user: user,image: image)
    end

    it "succeeds for critical actions" do
      get :edit, params: base_params.merge(id: other_description.id)
      expect(response).to be_success

      expect {
        patch :update, params: update_description_params.merge(id: other_description.id)
        other_description.reload
      }.to change(other_description,:text).
        to("NEWTEXT")

      expect {
        delete :destroy, params: base_params.merge(id: other_description.id)
        expect(response).to redirect_to(organization_descriptions_url(organization))
      }.to change { Description.exists?(other_description.id) }.
        from(true).to(false)
    end
  end
end
