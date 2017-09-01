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
#  index_assignments_on_image_id  (image_id)
#  index_assignments_on_user_id   (user_id)
#

RSpec.describe AssignmentsController do
  let(:assignment) { build_stubbed(:assignment) }

  include_context "injected user organization"
  
  before do
    allow(user_organization).
      to receive_message_chain(:assignments,:find).
      with('20').
      and_return(assignment)
  end

  context "GET #index" do
    let(:assignments) { double(:assignments) }

    before do
      allow(user_organization).
        to receive_message_chain(:assignments,:by_created_at,:page).
        with('2').
        and_return(assignments)
    end

    context "as an admin" do
      include_context "stubbed controller admin user"

      before do 
        get :index, params: { organization_id: 1, page: 2 }
      end

      it_behaves_like "a successful controller response"
    end

    context "as a non-admin" do
      include_context "stubbed controller editor user"

      before do 
        get :index, params: { organization_id: 1 }
      end

      it_behaves_like "an unsuccessful controller response"
    end
  end

  context "GET #show" do
    context "as an admin" do
      include_context "stubbed controller admin user"

      before do 
        get :show, params: { id: 20, organization_id: 1 }
      end

      it_behaves_like "a successful controller response"
    end

    context "as a non-admin" do
      include_context "stubbed controller editor user"

      before do 
        get :show, params: { id: 20, organization_id: 1 }
      end

      it_behaves_like "an unsuccessful controller response"
    end
  end

  context "GET #new" do
    before do
      allow(user_organization).
        to receive_message_chain(:assignments,:new).
        and_return(assignment)
    end
    
    context "as an admin" do
      include_context "stubbed controller admin user"

      before do 
        get :new, params: { organization_id: 1 } 
      end

      it_behaves_like "a successful controller response"
    end

    context "as a non-admin" do
      include_context "stubbed controller editor user"

      before do 
        get :new, params: { organization_id: 1 } 
      end

      it_behaves_like "an unsuccessful controller response"
    end
  end

  context "GET #edit" do
    context "as an admin" do
      include_context "stubbed controller admin user"

      before do 
        get :edit, params: { id: 20, organization_id: 1 }
      end

      it_behaves_like "a successful controller response"
    end

    context "as a non-admin" do
      include_context "stubbed controller editor user"

      before do 
        get :edit, params: { id: 20, organization_id: 1 }
      end

      it_behaves_like "an unsuccessful controller response"
    end
  end

  context "POST #create" do
    let(:assigned_user)  { double(:assigned_user) }
    let(:assigned_image) { double(:assigned_image) }

    before do
      allow(user_organization).
        to receive_message_chain(:users,:find).
        with('100').
        and_return(assigned_user)

      allow(user_organization).
        to receive_message_chain(:images,:find).
        with('200').
        and_return(assigned_image)

      allow(Assignment).
        to receive(:create).
        with(user: assigned_user,image: assigned_image).
        and_return(assignment)
    end
    
    let(:creation_params) do
      { user_id: 100, image_id: 200 }
    end

    context "as an admin" do
      include_context "stubbed controller admin user"

      before do 
        post :create, params: { organization_id: 1, assignment: creation_params } 
      end

      specify do 
        expect(response).to redirect_to(organization_assignment_path(user_organization,assignment)) 
      end
    end

    context "as a non-admin" do
      include_context "stubbed controller editor user"

      before do 
        post :create, params: { organization_id: 1, ssignment: creation_params }
      end

      it_behaves_like "an unsuccessful controller response"
    end
  end
end
