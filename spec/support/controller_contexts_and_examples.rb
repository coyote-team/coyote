# frozen_string_literal: true

RSpec.shared_context "signed-out user" do
  before do
    sign_out
  end
end

Coyote::Membership.each_role do |_, role_name|
  RSpec.shared_context "signed-in #{role_name} user" do
    # Assumes that in your spec you will define the organization
    let(:user) { create(:user) }

    let!(:user_membership) do
      create(:membership, role_name, user: user, organization: organization)
    end

    before do
      sign_in(user)
    end
  end
end

RSpec.shared_context "signed-in staff user" do
  let(:user) do
    create(:user, :staff, organization: organization)
  end

  before do
    sign_in(user)
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
    expect(response).to redirect_to(new_session_url)
  end

  it "sets a flash alert message" do
    expect(flash.alert).to be_present
  end
end
