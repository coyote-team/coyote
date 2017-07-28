# see https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs

RSpec.shared_context "signed-in admin" do
  let(:user) { build_stubbed(:user,:admin) }

  before do
    controller_login(user)
  end
end

RSpec.shared_context "signed-in editor" do
  let(:user) { build_stubbed(:user,:editor) }

  before do
    # Requires inclusion of Devise::Test::ControllerHelpers
    # see https://github.com/plataformatec/devise#controller-tests
    sign_in user
  end
end

RSpec.shared_examples "a successful controller response" do
  it "succeeds" do
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples "an unsuccessful controller response" do
  it "redirects the user to the root path" do
    expect(response).to redirect_to(new_user_session_url)
  end

  it "sets a flash alert message" do
    expect(flash.alert).to be_present
  end
end
