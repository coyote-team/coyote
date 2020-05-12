# frozen_string_literal: true

RSpec.describe "Accessing resource groups" do
  describe "with authorization" do
    include_context "API admin user"

    let(:resource_group) do
      create(:resource_group, :website, organization: user_organization)
    end

    let(:new_resource_group_params) do
      {
        name:        "website",
        webhook_uri: "https://test/test",
      }
    end

    it "POST /organizations/:id/resources_group" do
      expect {
        post api_resource_groups_path(user_organization.id), params: {resource_group: new_resource_group_params}, headers: auth_headers
        expect(response).to be_created
      }.to change(user_organization.resource_groups, :count)
        .from(1).to(2)

      user_organization.resource_groups.order(id: :desc).first.tap do |resource_group|
        expect(resource_group.name).to eq("website")
      end

      invalid_params = {resource_group: new_resource_group_params.except(:name)}
      post api_resource_groups_path, params: invalid_params, headers: auth_headers
      expect(response).to be_unprocessable
      expect(json_data).to have_key(:errors)
    end

    it "PATCH /resource_groups/:id" do
      expect {
        patch api_resource_group_path(resource_group.id), params: {resource_group: {name: "NEWNAME"}}, headers: auth_headers
        expect(response).to be_successful

        resource_group.reload
      }.to change(resource_group, :name)
        .to("NEWNAME")

      patch api_resource_group_path(resource_group.id), params: {resource_group: {name: nil}}, headers: auth_headers
      expect(response).to be_unprocessable
      expect(json_data).to have_key(:errors)
    end

    it "DELETE /resource_groups/:id" do
      delete api_resource_group_path(resource_group.id), headers: auth_headers
      expect(response).to be_successful

      expect(ResourceGroup.find_by(id: resource_group.id)).to be_nil
    end

    it "DELETE /resource_groups/:id with existing resources" do
      create(:resource, resource_groups: [resource_group])

      delete api_resource_group_path(resource_group.id), headers: auth_headers
      expect(response).to be_unprocessable
      expect(json_data).to have_key(:errors)

      expect(ResourceGroup.find_by(id: resource_group.id)).to eq(resource_group)
    end
  end

  describe "with multiple resource_groups" do
    include_context "API author user"

    let!(:user_org_resource_groups) do
      i = 0
      create_list(:resource_group, 3, organization: user_organization) do |resource_group|
        resource_group.default = i.zero?
        i += 1
      end
    end

    it "GET /organizations/:id/resource_groups" do
      request_path = api_resource_groups_path(user_organization)
      get request_path, headers: auth_headers

      expect(response).to be_successful

      resource_groups = json_data.fetch(:data)
      expect(resource_groups.size).to eq(4)

      ids = resource_groups.map { |r| r.fetch(:id).to_i }
      expect([user_organization.resource_groups.default.first.id] + user_org_resource_groups.map(&:id)).to include(*ids)

      link_paths = json_data.fetch(:links).inject({}) { |result, (rel, href)|
        uri = URI.parse(href)
        result.merge(rel.to_sym => uri.request_uri)
      }

      expected_link_paths = {
        self: CGI.unescape(request_path),
      }

      expect(link_paths.size).to eq(expected_link_paths.size)

      expected_link_paths.each do |name, path|
        actual_path = CGI.unescape(link_paths.fetch(name))
        expect(actual_path).to eq(path), "Expected '#{name}' link to match '#{path}' but got '#{actual_path}'"
      end
    end
  end

  describe "with a resource group" do
    include_context "API author user"

    let(:resource_group) do
      create(:resource_group, organization: user_organization, webhook_uri: "https://test/test")
    end

    it "GET /resource_groups/:id" do
      get api_resource_group_path(resource_group.id), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |data|
        expect(data).to have_id(resource_group.id.to_s)
        expect(data).to have_type("resource_group")

        expect(data).to have_attribute(:name).with_value(resource_group.name)
        expect(data).to have_attribute(:webhook_uri).with_value(resource_group.webhook_uri)
      end
    end
  end

  describe "without authorization" do
    include_context "API access headers"

    let(:resource_group) { create(:resource_group) }

    it "returns an error" do
      get api_resource_groups_path(resource_group.organization_id), headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      get api_resource_group_path(resource_group.organization_id, resource_group.id), headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      post api_resource_groups_path(resource_group.organization_id), params: {resource: {}}, headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)
    end
  end
end
