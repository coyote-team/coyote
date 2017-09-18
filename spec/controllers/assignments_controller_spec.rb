# == Schema Information
#
# Table name: assignments
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  image_id   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_assignments_on_user_id_and_image_id  (user_id,image_id) UNIQUE
#

RSpec.describe AssignmentsController do
  let(:organization) { create(:organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:image) { create(:image,organization: organization) }

  let(:assignment) { create(:assignment,user: user,image: image) }

  let(:assignment_params) do
    base_params.merge(id: assignment.id)
  end

  let(:new_assignment_user) { create(:user,organization: organization) }

  let(:new_assignment_image) { create(:image,organization: organization) }

  let(:new_assignment_params) do
    base_params.merge(assignment: { user_id: new_assignment_user.id, image_id: new_assignment_image.id })
  end

  let(:update_assignment_params) do
    assignment_params.merge(assignment: { image_id: image.id, user_id: new_assignment_user.id })
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :index, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        get :show, params: base_params.merge(id: 1)
        expect(response).to redirect_to(new_user_session_url)

        get :edit, params: base_params.merge(id: 1)
        expect(response).to redirect_to(new_user_session_url)

        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: base_params.merge(assignment: {})
        expect(response).to redirect_to(new_user_session_url)

        patch :update, params: base_params.merge(id: 1)
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
        get :edit, params: assignment_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        get :new, params: base_params
      }.to raise_error(Pundit::NotAuthorizedError)

      expect {
        patch :update, params: update_assignment_params
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

      get :edit, params: assignment_params
      expect(response).to be_success

      get :new, params: base_params
      expect(response).to be_success
    end

    it "can create, update, and destroy assignments" do
      expect {
        patch :update, params: update_assignment_params
        expect(response).to be_redirect
        assignment.reload
      }.to change(assignment,:user).
        to(new_assignment_user)

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
