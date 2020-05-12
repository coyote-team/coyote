# frozen_string_literal: true

RSpec.describe "Accessing a user profile" do
  describe "with authorization" do
    include_context "API author user"

    it "GET /profile" do
      get api_user_path, headers: auth_headers

      expect(response).to be_successful

      organizations = json_data.fetch(:included, [])
      expect(organizations.size).to eq(user.organizations.size)
      user.organizations.each do |organization|
        serialized_organization = organizations.find { |other_organization| other_organization[:id].to_i == organization.id }
        expect(serialized_organization.dig(:attributes, :name)).to eq(organization.name)
      end
    end
  end

  describe "without authorization" do
    include_context "API access headers"

    it "returns an error" do
      get api_user_path, headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)
    end
  end
end
