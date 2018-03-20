# == Schema Information
#
# Table name: assignments
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#  resource_id :integer          not null
#
# Indexes
#
#  index_assignments_on_resource_id_and_user_id  (resource_id,user_id) UNIQUE
#

RSpec.describe AssignmentsController do
  let(:organization) { create(:organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:resource) { create(:resource,organization: organization) }

  let(:assignment) { create(:assignment,user: user,resource: resource) }

  let(:assignment_params) do
    base_params.merge(id: assignment.id)
  end

  let(:new_assignment_user) { create(:user,organization: organization) }

  let(:new_assignment_resource) { create(:resource,organization: organization) }

  let(:new_assignment_params) do
    base_params.merge(assignment: { user_id: new_assignment_user.id, resource_ids: [new_assignment_resource.id] })
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: base_params.merge(id: 1)
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: base_params.merge(assignment: {})
        expect(response).to redirect_to(new_user_session_url)

        delete :destroy, params: base_params.merge(id: 1)
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an editor" do
    include_context "signed-in editor user"

    it "fails for basic actions" do
      expect {
        get :index, params: base_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :show, params: assignment_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        delete :destroy, params: assignment_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        post :create, params: new_assignment_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "as an admin" do
    include_context "signed-in admin user"

    it "can view and edit assignments" do
      get :index, params: base_params
      expect(response).to be_success

      get :show, params: assignment_params
      expect(response).to be_success
    end

    it 'can create and destroy assignments' do
      expect {
        delete :destroy, params: assignment_params
        expect(response).to be_redirect
      }.to change { Assignment.exists?(assignment.id) }.
        from(true).to(false)

      expect {
        post :create, params: new_assignment_params
        expect(response).to be_redirect
      }.to change(new_assignment_user.assignments,:count).
        from(0).to(1)
    end
  end
end
