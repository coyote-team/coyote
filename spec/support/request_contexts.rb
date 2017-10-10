Coyote::Membership.each_role do |_,role_name|
  RSpec.shared_context "API #{role_name} user" do
    let(:user_organization) { create(:organization) }

    let(:user) { create(:user) }

    let!(:user_membership) do
      create(:membership,role_name,user: user,organization: user_organization)
    end

    let(:auth_headers) do
      { Authorization: user.authentication_token }
    end
  end
end
