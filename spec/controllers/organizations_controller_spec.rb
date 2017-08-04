# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  title      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

RSpec.describe OrganizationsController do
  let(:organization) { build_stubbed(:organization) }
  let(:organizations) { build_stubbed_list(:organization,3) }

  before do
    allow(Organization).to receive(:find).with('1').and_return(organization)
    allow(Organization).to receive_message_chain(:all,:page).and_return(organizations)
  end

  context "GET #index" do
    context "as a logged-in viewer user" do
      include_context "stubbed controller viewer user"
      before { get :index }
      it_behaves_like "a successful controller response"
    end

    context "without a logged-in user" do
      before { get :index }
      it_behaves_like "a sign-in redirect controller response"
    end
  end

  context "GET #show" do
    context "as a logged-in viewer user" do
      include_context "stubbed controller viewer user"

      before do 
        get :show, params: { id: 1 } 
      end

      it_behaves_like "a successful controller response"
    end

    context "without a logged-in user" do
      before do 
        get :show, params: { id: 1 } 
      end

      it_behaves_like "a sign-in redirect controller response"
    end
  end

  context "GET #new" do
    context "as a logged-in viewer user" do
      include_context "stubbed controller viewer user"
      before { get :new }
      it_behaves_like "a successful controller response"
    end

    context "without a logged-in user" do
      before { get :new }
      it_behaves_like "a sign-in redirect controller response"
    end
  end

  context "GET #edit" do
    context "as a logged-in viewer user" do
      include_context "stubbed controller viewer user"

      before do 
        get :edit, params: { id: 1 } 
      end

      it_behaves_like "a successful controller response"
    end

    context "without a logged-in user" do
      before do 
        get :edit, params: { id: 1 }
      end

      it_behaves_like "a sign-in redirect controller response"
    end
  end

  context "POST #create" do
    let(:creation_params) do
      { title: "XYZ  Museum" }
    end

    before do
      allow(Organization).
        to receive(:create).
        with(an_instance_of(ActionController::Parameters)).
        and_return(organization)
    end

    context "as a logged-in viewer user" do
      include_context "stubbed controller viewer user"

      before do
        post :create, params: { organization: creation_params }
      end

      specify { expect(response).to redirect_to(organization_path(organization)) }
    end

    context "with bad data" do
      include_context "stubbed controller viewer user"

      before do 
        allow(organization).to receive_messages(valid?: false)
        post :create, params: { organization: creation_params }
      end

      specify { expect(response.status).to eq(200) }
    end
    
    context "without a logged-in user" do
      before do 
        post :create, params: { organization: creation_params }
      end

      it_behaves_like "a sign-in redirect controller response"

      it "does not allow an Organization to be created" do
        expect(Organization).not_to have_received(:create)
      end
    end
  end

  context "PATCH #update" do
    let(:update_params) do
      { title: "123 Space" }
    end

    before do
      allow(organization).
        to receive(:update_attributes).
        with(an_instance_of(ActionController::Parameters)).
        and_return(true)
    end

    context "as a logged-in viewer user" do
      include_context "stubbed controller viewer user"

      before do 
        patch :update, params: { id: "1", organization: update_params } 
      end

      specify { expect(response).to redirect_to(organization_path(organization)) }
    end

    context "with invalid data" do
      include_context "stubbed controller viewer user"

      before do
        allow(organization).to receive_messages(update_attributes: false)
        patch :update, params: { id: "1", organization: update_params  }
      end

      specify { expect(response.status).to eq(200) }
    end
    
    context "without a logged-in user" do
      before do 
        patch :update,params: { id: "1", organization: update_params  }
      end

      it_behaves_like "a sign-in redirect controller response"

      it "does not allow an Organization to be updated" do
        expect(organization).not_to have_received(:update_attributes)
      end
    end
  end
end
