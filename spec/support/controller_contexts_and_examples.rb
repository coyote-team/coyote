# see https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs

%i[viewer author editor admin super_admin staff].each do |role_name|
  RSpec.shared_context "stubbed controller #{role_name} user" do
    let(:user) { build_stubbed(:user,role_name) }

    before do
      controller_login(user)
    end
  end
end

RSpec.shared_context "injected user organization" do
  let(:user_organization) { build_stubbed(:organization) }

  before do
    subject.current_organization = user_organization
  end
end

RSpec.shared_examples "a successful controller response" do
  it "succeeds" do
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples "an unsuccessful controller response" do
  it "redirects the user" do
    expect(response).to be_redirect
  end

  it "sets a flash alert message" do
    expect(flash.alert).to be_present
  end
end

RSpec.shared_examples "a sign-in redirect controller response" do
  it "redirects the user to the sign-in URL" do
    expect(response).to redirect_to(new_user_session_url)
  end

  it "sets a flash alert message" do
    expect(flash.alert).to be_present
  end
end
