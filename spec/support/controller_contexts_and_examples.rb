# see https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs

RSpec.shared_context "signed-out user" do
  before do
    sign_in nil, :scope => :user
  end
end

Coyote::Membership.each_role do |_,role_name|
  RSpec.shared_context "signed-in #{role_name} user" do
    let(:user) do 
      create(:user,organization: organization,role: role_name) 
    end

    before do
      sign_in(user) # uses https://github.com/plataformatec/devise/blob/master/lib/devise/test/controller_helpers.rb
    end
  end
end

RSpec.shared_context "signed-in staff user" do
  let(:user) do 
    create(:user,:staff,organization: organization)
  end

  before do
    sign_in(user) # uses https://github.com/plataformatec/devise/blob/master/lib/devise/test/controller_helpers.rb
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
