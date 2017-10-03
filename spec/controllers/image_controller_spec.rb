RSpec.describe ImagesController do
  let(:organization) { create(:organization) }
  let(:context) { create(:context,organization: organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:image_params) do
    base_params.merge(id: image.id)
  end

  let(:new_image_params) do
    image = attributes_for(:image)
    image.merge!(context_id: context.id)
    base_params.merge(image: image)
  end

  let(:update_image_params) do
    image_params.merge(image: { title: "NEWTITLE" })
  end

  let(:image) { create(:image,organization: organization) }  

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: image_params
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: image_params
        expect(response).to redirect_to(new_user_session_url)

        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: new_image_params
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: update_image_params
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: update_image_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an author" do
    include_context "signed-in author user"

    it "succeeds for basic actions" do
      get :index, params: base_params
      expect(response).to be_success

      get :show, params: image_params
      expect(response).to be_success

      expect {
        get :edit, params: image_params
      }.to raise_error(Pundit::NotAuthorizedError)

      get :new, params: base_params
      expect(response).to be_success

      expect {
        post :create, params: new_image_params
        expect(response).to be_redirect
      }.to change(organization.images,:count).by(1)

      expect {
        patch :update, params: update_image_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: update_image_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "as an editor" do
    include_context "signed-in editor user"

    it "succeeds for critical actions" do
      get :edit, params: image_params
      expect(response).to be_success

      expect {
        patch :update, params: update_image_params
        expect(response).to redirect_to([organization,image])
        image.reload
      }.to change(image,:title).to("NEWTITLE")

      expect {
        delete :destroy, params: update_image_params
        expect(response).to redirect_to(organization_images_url(organization))
      }.to change { Image.exists?(image.id) }.
        from(true).to(false)
    end
  end
end
