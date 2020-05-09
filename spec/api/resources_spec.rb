# frozen_string_literal: true

RSpec.describe "Accessing resources" do
  describe "with authorization" do
    include_context "API editor user"

    let(:resource_group) do
      create(:resource_group, :website, organization: user_organization)
    end

    let(:new_resource_params) do
      attributes_for(:resource).merge(resource_group_id: resource_group.id)
    end

    let(:existing_resource) do
      create(:resource, organization: user_organization, source_uri: Faker::Internet.unique.url)
    end

    it "POST /organizations/:id/resources" do
      expect {
        post api_resources_path(user_organization.id), params: {resource: new_resource_params}, headers: auth_headers
        expect(response).to be_created
      }.to change(user_organization.resources, :count)
        .from(0).to(1)

      new_resource = user_organization.resources.first.tap do |resource|
        expect(resource.title).to eq("Mona Lisa")
        expect(resource.resource_group_title).to eq("website")
      end

      invalid_params = {resource: new_resource_params.except(:title).merge(canonical_id: "rewriting-canonical-id-for-test-reasons")}
      post api_resources_path, params: invalid_params, headers: auth_headers
      expect(response).to be_unprocessable
      expect(json_data).to have_key(:errors)

      update_params = {resource: new_resource_params.merge(canonical_id: new_resource.canonical_id, title: "This is the new title; it should update the old resource")}
      post api_resources_path, params: update_params, headers: auth_headers
      new_resource.reload
      expect(new_resource.title).to eq("This is the new title; it should update the old resource")
      expect(new_resource.resource_group_title).to eq("website")
    end

    it "POST /organizations/:id/resources without a title" do
      expect {
        post api_resources_path(user_organization.id), params: {resource: new_resource_params.except(:title)}, headers: auth_headers
        expect(response).to be_created
      }.to change(user_organization.resources, :count)
        .from(0).to(1)

      user_organization.resources.first.tap do |resource|
        expect(resource.title).to eq(Resource::DEFAULT_TITLE)
        expect(resource.resource_group_title).to eq("website")
      end
    end

    it "PATCH /resources/:id" do
      expect {
        patch api_resource_path(existing_resource.canonical_id), params: {resource: {title: "NEWTITLE"}}, headers: auth_headers
        expect(response).to be_successful

        existing_resource.reload
      }.to change(existing_resource, :title)
        .to("NEWTITLE")

      patch api_resource_path(existing_resource.canonical_id), params: {resource: {title: nil}}, headers: auth_headers
      expect(response).to be_unprocessable
      expect(json_data).to have_key(:errors)
    end

    it "PATCH /resources/:id with multiple resource group IDs" do
      default_resource_group = user_organization.resource_groups.default.first
      params = {
        resource: {
          resource_group_ids: [
            default_resource_group.id,
            resource_group.id,
          ],
        },
      }

      expect {
        patch api_resource_path(existing_resource.canonical_id), params: params, headers: auth_headers
        expect(response).to be_successful

        existing_resource.reload
        existing_resource.resource_groups.reload
      }.to change { existing_resource.resource_groups.to_a }
        .to([
          default_resource_group,
          resource_group,
        ])
    end
  end

  describe "with multiple resources" do
    include_context "API author user"

    let(:default_page_size) do
      Rails.configuration.x.resource_api_page_size
    end

    let(:user_org_resource_count) do
      Rails.configuration.x.resource_api_page_size + 1 # to force pagination to occur
    end

    let!(:user_org_resources) do
      create_list(:resource, user_org_resource_count, organization: user_organization, priority_flag: true) do |resource|
        resource.source_uri = Faker::Internet.unique.url
      end
    end

    let(:represented_resource) do
      user_org_resources.first
    end

    let!(:older_resource) do
      create(:resource, organization: user_organization, source_uri: Faker::Internet.unique.url, title: "This should be filtered out using the updated_at_gt filter").tap do |resource|
        resource.update_attribute(:updated_at, 10.days.ago)
      end
    end

    let!(:approved_resource) do
      create(:resource, organization: user_organization, source_uri: Faker::Internet.unique.url, title: "This should be the only response using the with_approved_representations filter").tap do |resource|
        create(:representation, resource: resource, status: "approved")
      end
    end

    before do
      create(:representation, resource: represented_resource, text: 'can search for the term "polyphonic"')
      create(:resource, source_uri: Faker::Internet.unique.url, title: "Current user should not be seeing this due to other org privacy restrictions")
    end

    it "GET /organizations/:id/resources" do
      request_path = api_resources_path(user_organization)
      get request_path, headers: auth_headers

      expect(response).to be_successful

      expected_link_paths = {
        self:  CGI.unescape(request_path),
        first: CGI.unescape(api_resources_path(page: {number: 1, size: default_page_size})),
        next:  CGI.unescape(api_resources_path(page: {number: 2, size: default_page_size})),
      }

      first_page = json_data.fetch(:data)
      expect(first_page.size).to eq(user_org_resource_count - 1)

      ids = first_page.map { |r| r.fetch(:id).to_i }
      expect(user_org_resources.map(&:id)).to include(*ids)

      link_paths = json_data.fetch(:links).inject({}) { |result, (rel, href)|
        uri = URI.parse(href)
        result.merge(rel.to_sym => uri.request_uri)
      }

      expect(link_paths.size).to eq(expected_link_paths.size)

      expected_link_paths.each do |name, path|
        actual_path = CGI.unescape(link_paths.fetch(name))
        expect(actual_path).to eq(path), "Expected '#{name}' link to match '#{path}' but got '#{actual_path}'"
      end

      filter = {identifier_or_title_or_representations_text_cont_all: "polyphonic"}

      request_path = api_resources_path(user_organization, filter: filter)
      get request_path, headers: auth_headers

      data = json_data.fetch(:data)
      expect(data.size).to eq(1)
    end

    it "GET /organizations/:id/resources filtered by updated_at" do
      # First, make sure all resources are included here
      request_path = api_resources_path(user_organization, page: {number: user_organization.resources.count / default_page_size})
      get request_path, headers: auth_headers
      expect(json_data[:data].size).to eq(2) # Including the resource updated 10 days ago
      expect(json_data[:links].keys).to eq(%w[self first previous next])

      request_path = api_resources_path(user_organization, filter: {updated_at_gt: 9.days.ago}, page: {number: user_organization.resources.count / default_page_size})
      get request_path, headers: auth_headers
      expect(json_data[:data].size).to eq(2) # Just the recently updated resources
      expect(json_data[:links].keys).to eq(%w[self first previous])
    end

    it "GET /organizations/:id/resources filtered by with_approved_representations" do
      request_path = api_resources_path(user_organization, filter: {scope: "with_approved_representations"})
      get request_path, headers: auth_headers
      expect(json_data[:data].map { |r| r.fetch(:id).to_i }).to eq([approved_resource.id])
    end

    it "GET /organizations/:id/resources filtered multiple ways" do
      request_path = api_resources_path(user_organization, filter: {scope: %w[unrepresented with_approved_representations]})
      get request_path, headers: auth_headers
      expect(json_data[:data].map { |r| r.fetch(:id).to_i }).to eq([])
    end

    it "GET /organizations/:id/resources filtered by source_uri" do
      request_path = api_resources_path(user_organization, filter: {source_uri_eq_any: "#{approved_resource.source_uri} #{older_resource.source_uri}"})
      get request_path, headers: auth_headers
      expect(json_data[:data].map { |r| r.fetch(:id).to_i }).to eq([older_resource.id, approved_resource.id])
      expect(json_data[:links].keys).to eq(%w[self first]) # Shouldn't return any other (non-matching) resources
    end

    it "POST /organizations/:id/resources/get filtered by source_uri" do
      request_path = get_api_resources_path(user_organization)
      post request_path, headers: auth_headers, params: {filter: {source_uri_eq_any: "#{approved_resource.source_uri} #{older_resource.source_uri}"}}
      # TODO: Remove the 'sort' from here - this is dependent on ironing out the ordering TODO in RecordFilter
      expect(json_data[:data].map { |r| r.fetch(:id).to_i }.sort).to eq([older_resource.id, approved_resource.id])
      expect(json_data[:links].keys).to eq(%w[self first]) # Shouldn't return any other (non-matching) resources
    end
  end

  describe "with a resource" do
    include_context "API author user"

    let(:resource) do
      create(:resource, organization: user_organization)
    end

    it "GET /resources/:id" do
      get api_resource_path(resource.identifier), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |data|
        expect(data).to have_id(resource.id.to_s)
        expect(data).to have_type("resource")

        expect(data).to have_attribute(:resource_type).with_value(resource.resource_type)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)

        expect(data).to have_relationships(:organization, :representations)
      end
    end

    it "GET /resources/:id with canonical ID" do
      get api_resource_path(resource.canonical_id), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |data|
        expect(data).to have_id(resource.id.to_s)
        expect(data).to have_type("resource")

        expect(data).to have_attribute(:resource_type).with_value(resource.resource_type)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)

        expect(data).to have_relationships(:organization, :representations)
      end
    end
  end

  describe "without authorization" do
    include_context "API access headers"

    let(:resource) { create(:resource) }

    it "returns an error" do
      get api_resources_path(resource.organization_id), headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      get api_resource_path(resource.organization_id, resource.id), headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      post api_resources_path(resource.organization_id), params: {resource: {}}, headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)
    end
  end
end
