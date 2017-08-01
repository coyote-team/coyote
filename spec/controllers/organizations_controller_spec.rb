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
      before { get :show, id: 1 }
      it_behaves_like "a successful controller response"
    end

    context "without a logged-in user" do
      before { get :show, id: 1 }
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

      before { get :edit, id: 1 }
      it_behaves_like "a successful controller response"
    end

    context "without a logged-in user" do
      before { get :edit, id: 1 }
      it_behaves_like "a sign-in redirect controller response"
    end
  end

  context "POST #create" do
    let(:creation_params) do
      { "title" => "XYZ  Museum" }
    end

    before do
      allow(Organization).to receive(:create).with(creation_params).and_return(organization)
    end

    context "as a logged-in viewer user" do
      include_context "stubbed controller viewer user"
      before { post :create, organization: creation_params }
      specify { expect(response).to redirect_to(organization_path(organization)) }
    end

    context "with bad data" do
      include_context "stubbed controller viewer user"

      before do 
        allow(organization).to receive_messages(valid?: false)
        post :create, organization: creation_params 
      end

      specify { expect(response).to render_template("new") }
    end
    
    context "without a logged-in user" do
      before { post :create, organization: creation_params }

      it_behaves_like "a sign-in redirect controller response"

      it "does not allow an Organization to be created" do
        expect(Organization).not_to have_received(:create)
      end
    end
  end

  context "PATCH #update" do
    let(:update_params) do
      { "title" => "123 Space" }
    end

    before do
      allow(organization).to receive(:update_attributes).with(update_params).and_return(true)
    end

    context "as a logged-in viewer user" do
      include_context "stubbed controller viewer user"
      before { patch :update, id: "1", organization: update_params }
      specify { expect(response).to redirect_to(organization_path(organization)) }
    end

    context "with invalid data" do
      include_context "stubbed controller viewer user"

      before do
        allow(organization).to receive_messages(update_attributes: false)
        patch :update, id: "1", organization: update_params 
      end

      specify { expect(response).to render_template("edit") }
    end
    
    context "without a logged-in user" do
      before { patch :update, id: "1", organization: update_params }

      it_behaves_like "a sign-in redirect controller response"

      it "does not allow an Organization to be updated" do
        expect(organization).not_to have_received(:update_attributes)
      end
    end
  end
end
