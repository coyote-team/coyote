Coyote::Membership.each_role do |_,role_name|
  RSpec.shared_context "API #{role_name} user" do
    let(:user_organization) { create(:organization) }

    let(:user) { create(:user) }

    let!(:user_membership) do
      create(:membership,role_name,user: user,organization: user_organization)
    end

    let(:api_headers) do
      mime_type = Rails.configuration.x.api_mime_type_template % { version: 'v1' }
      { Accept: mime_type }
    end

    let(:auth_headers) do
      api_headers.merge(Authorization: user.authentication_token)
    end
  end
end
