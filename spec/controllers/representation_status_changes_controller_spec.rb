RSpec.describe RepresentationStatusChangesController do
  let(:organization) { create(:organization) }
  let(:representations) do
    create_list(:representation,2,:ready_to_review,organization: organization)
  end

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:change_params) do
    base_params.merge({
      representation_status_change: {
        status: 'approved',
        representation_ids: representations.map(&:id)
      }
    })
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      post :create, params: change_params
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  context 'as a viewer user' do
    include_context "signed-in viewer user"

    it 'fails for creation' do
      expect {
        post :create, params: change_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'as an admin user' do
    include_context 'signed-in admin user'

    it 'succeeds' do
      expect {
        post :create, params: change_params
        representations.map(&:reload)
      }.to change {
        representations.map(&:status).uniq
      }.from(['ready_to_review']).to(['approved'])
    end
  end
end
