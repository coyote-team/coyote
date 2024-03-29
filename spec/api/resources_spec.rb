# frozen_string_literal: true

RSpec.describe "Accessing resources" do
  describe "with authorization" do
    include_context "with an editor user"
    include_context "without webhooks"

    let(:resource_group) do
      create(:resource_group, :website, organization: user_organization, webhook_uri: "https://example.com/webhook")
    end

    let(:new_resource_params) do
      attributes_for(:resource).merge(resource_group_id: resource_group.id)
    end

    let(:existing_resource) do
      create(:resource, organization: user_organization)
    end

    it "POST /organizations/:id/resources" do
      expect {
        post api_resources_path(user_organization.id), params: {resource: new_resource_params}, headers: auth_headers
        expect(response).to be_created
      }.to change(user_organization.resources, :count)
        .from(0).to(1)

      new_resource = user_organization.resources.first.tap do |resource|
        expect(resource.name).to eq("Mona Lisa")
        expect(resource.resource_group_name).to eq("website")
      end

      # An explicitly blank name will cause a rejection
      invalid_params = {resource: new_resource_params.merge(canonical_id: "rewriting-canonical-id-for-test-reasons", name: "")}
      post api_resources_path, params: invalid_params, headers: auth_headers
      expect(response).to be_unprocessable
      expect(json_data).to have_key(:errors)

      update_params = {resource: new_resource_params.merge(name: "This is the new name; it should update the old resource")}
      post api_resources_path, params: update_params, headers: auth_headers
      new_resource.reload
      expect(new_resource.name).to eq("This is the new name; it should update the old resource")
      expect(new_resource.resource_group_name).to eq("website")

      # It should never have triggered a webhook request
      expect(NotifyWebhookWorker.jobs).to be_empty
    end

    it "POST /organizations/:id/resources without a name" do
      expect {
        post api_resources_path(user_organization.id), params: {resource: new_resource_params.except(:name)}, headers: auth_headers
        expect(response).to be_created
      }.to change(user_organization.resources, :count)
        .from(0).to(1)

      user_organization.resources.first.tap do |resource|
        expect(resource.name).to eq(Resource::DEFAULT_NAME)
        expect(resource.resource_group_name).to eq("website")
      end
    end

    it "PATCH /resources/:id" do
      expect {
        patch api_resource_path(existing_resource.id), params: {resource: {name: "NEWNAME"}}, headers: auth_headers
        expect(response).to be_successful

        existing_resource.reload
      }.to change(existing_resource, :name)
        .to("NEWNAME")

      patch api_resource_path(existing_resource.id), params: {resource: {name: nil}}, headers: auth_headers
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
        patch api_resource_path(existing_resource.id), params: params, headers: auth_headers
        expect(response).to be_successful

        existing_resource.reload
        existing_resource.resource_groups.reload
      }.to change { existing_resource.resource_groups.reload.by_id.to_a }
        .to([
          default_resource_group,
          resource_group,
        ])
    end

    it "DELETE /resources/:id" do
      expect {
        delete api_resource_path(existing_resource.id), headers: auth_headers
      }.to change {
        existing_resource.reload.is_deleted?
      }.from(false).to(true)
      expect(response).to be_successful
    end

    it "DELETE /resources/:canonical_id" do
      existing_resource.update_attribute(:canonical_id, "canonical-yey")
      expect {
        delete api_canonical_resource_path("canonical-yey"), headers: auth_headers
      }.to change {
        existing_resource.reload.is_deleted?
      }.from(false).to(true)
      expect(response).to be_successful
    end

    it "DELETE /resources/:id with a resource we don't own" do
      outside_resource = create(:resource)

      expect {
        delete api_resource_path(outside_resource.id), headers: auth_headers
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    describe "creating many resources" do
      let!(:license) { License.find_by(name: attributes_for(:license, :universal)[:name]) || create(:license, :universal) }
      let(:short) { user_organization.meta.find_by!(name: "Alt") }
      let(:long) { user_organization.meta.find_by!(name: "Long") }

      let(:representation_attributes) { attributes_for(:representation, :approved) }

      let!(:existing_resource) { create(:resource, host_uris: Array.new(3) { Faker::Internet.unique.url }, organization: user_organization) }
      let(:existing_resource_uris) { existing_resource.host_uris }
      let!(:existing_nested_resource) {
        create(:resource, organization: user_organization).tap do |resource|
          create(:representation, representation_attributes.merge(metum: long, resource: resource))
        end
      }

      let(:new_resource_params) do
        attributes_for(:resource, resource_group_id: resource_group.id)
      end

      let(:new_nested_resource_params) {
        attributes_for(:resource, representations: [
          attributes_for(:representation).merge(metum: long.name),
        ], resource_group_id: resource_group.id)
      }

      let(:existing_resource_params) {
        existing_resource.attributes.slice("source_uri").merge(
          representations: [representation_attributes],
        )
      }

      let(:existing_nested_resource_params) {
        existing_nested_resource.attributes.slice("source_uri").merge(
          representations: [representation_attributes.merge(metum: long.name)],
        )
      }

      it "POST /organizations/:id/resources/create creates new resources by source_uri, and appends representations" do
        params = {resources: [
          new_resource_params,
          new_nested_resource_params,
          existing_resource_params,
          existing_nested_resource_params,
        ]}

        expect {
          post create_many_api_resources_path(user_organization.id), params: params, as: :json, headers: auth_headers
          expect(response).to be_created
        }.to change(user_organization.resources, :count)
          .from(2).to(4)

        # It should add a new representation to the resource that had none
        representation = existing_resource.representations.first
        expect(representation.metum).to eq(short)
        expect(representation.license).to eq(license)
        expect(representation.text).to eq(representation_attributes[:text])

        # It should prevent creation of a duplicate representation on the resource that already had one
        expect(existing_nested_resource.representations.count).to eq(1)

        # It should also not modify the existing representation since it was a duplicate
        representation = existing_nested_resource.representations.first
        expect(representation.metum).to eq(long) # It should not have updated the metum to short
      end

      it "POST /organizations/:id/resources/create clearly explains bad requests" do
        params = {resources: []}

        # Ensure the controller will trap errors
        rescuing_errors do
          # Generate a request with empty resources
          post create_many_api_resources_path(user_organization.id), params: params, as: :json, headers: auth_headers
          expect(response).to be_unprocessable
          expect(json_data[:error]).to eq(I18n.t("actioncontroller.parameter_missing", param: "resources"))
        end
      end

      it "POST /organizations/:id/resources/create returns a mix of errors and success when some things fail" do
        params = {resources: [
          new_resource_params.except(:source_uri, :name),
          new_nested_resource_params,
          existing_resource_params,
          existing_nested_resource_params.merge(resource_type: "still_image"),
        ]}

        expect {
          post create_many_api_resources_path(user_organization.id), params: params, as: :json, headers: auth_headers
          expect(response).to be_unprocessable
        }.to change(user_organization.resources, :count)
          .from(2).to(3)

        # It should add a new representation to the resource that had none
        representation = existing_resource.representations.first
        expect(representation.metum).to eq(short)
        expect(representation.license).to eq(license)
        expect(representation.text).to eq(representation_attributes[:text])

        # It should prevent creation of a duplicate representation on the resource that already had one, and
        expect(existing_nested_resource.representations.count).to eq(1)

        # It should also not modify the existing representation since it was a duplicate
        representation = existing_nested_resource.representations.first
        expect(representation.metum).to eq(long) # It should not have updated the metum to short

        # FINALLY, it should render data AND errors
        # 1. Data
        expect(json_data[:data].size).to eq(2)
        expect(json_data[:data]).to all(have_attribute(:source_uri))

        # 2. Errors
        expect(json_data[:errors].size).to eq(2)
        expect(json_data[:errors][0][:title]).to eq("Invalid source_uri")
        expect(json_data[:errors][1][:title]).to eq("Invalid resource_type")
      end

      it "POST /organizations/:id/resources/create does not add representations when some already exist" do
        new_representation = attributes_for(:representation, metum_id: existing_nested_resource.representations.first.metum_id)
        params = {resources: [
          existing_nested_resource_params.merge(representations: [new_representation]),
          existing_resource_params,
        ]}

        expect {
          post create_many_api_resources_path(user_organization.id), params: params, as: :json, headers: auth_headers
          expect(response).to be_successful
        }.not_to change(user_organization.resources, :count)

        # It should not modify the existing representation
        expect(existing_nested_resource.representations.count).to eq(1)
        representation = existing_nested_resource.representations.first

        # It should include the original representation in the response
        # expect(json_data[:included]).to include(have_type("representation").and(have_id(representation.id.to_s)))
        expect(json_data[:included]).to include(have_type("representation").and(have_id(representation.id.to_s).and(have_attribute(:text).with_value(representation_attributes[:text]))))
        expect(json_data[:data].first).to have_relationship(:representations).with_data(
          [
            {
              id:   representation.id.to_s,
              type: "representation",
            }.stringify_keys,
          ],
        )

        # It should create a new representation on the representation-less resource
        representation = existing_resource.representations.first
        expect(representation.metum).to eq(short)
        expect(representation.license).to eq(license)
        expect(representation.text).to eq(representation_attributes[:text])

        expect(json_data[:included]).to include(have_type("representation").and(have_id(representation.id.to_s).and(have_attribute(:text).with_value(representation_attributes[:text]))))
        expect(json_data[:data].second).to have_relationship(:representations).with_data(
          [
            {
              id:   representation.id.to_s,
              type: "representation",
            }.stringify_keys,
          ],
        )
      end

      it "POST /organizations/:id/resources/create joins host URIs" do
        params = {resources: [
          existing_resource_params.merge(host_uris: ["http://www.other-host-uri-is-here-yay.com/scrmpth"]),
        ]}

        # It should union the host_uris from the original resource
        expect {
          post create_many_api_resources_path(user_organization.id), params: params, as: :json, headers: auth_headers
          expect(response).to be_created
        }.to change { existing_resource.reload.host_uris }
          .from(existing_resource_uris).to(existing_resource_uris + ["http://www.other-host-uri-is-here-yay.com/scrmpth"])
      end

      it "POST /organizations/:id/resources/create accepts new resource groups" do
        new_resource_group = create(:resource_group, organization: user_organization)
        resource_group_ids = existing_resource.resource_group_ids

        # It should add new_resource_group using the `resource_group_id` attribute
        expect {
          post create_many_api_resources_path(user_organization.id), params: {resources: [
            existing_resource_params.merge(resource_group_id: new_resource_group.id),
          ]}, as: :json, headers: auth_headers
          expect(response).to be_created
        }.to change { existing_resource.reload.resource_group_ids }
          .from(resource_group_ids).to(resource_group_ids + [new_resource_group.id])

        # It should add another_new_resource_group using the `resource_group_ids` attribute
        another_new_resource_group = create(:resource_group, organization: user_organization)
        expect {
          post create_many_api_resources_path(user_organization.id), params: {resources: [
            existing_resource_params.merge(resource_group_ids: [another_new_resource_group.id], union_resource_groups: true),
          ]}, as: :json, headers: auth_headers
          expect(response).to be_created
        }.to change { existing_resource.reload.resource_group_ids }
          .from(resource_group_ids + [new_resource_group.id]).to(resource_group_ids + [new_resource_group.id, another_new_resource_group.id])
      end

      it "POST /organizations/:id/resources/create accepts a hash format" do
        params = {resources: {
          "0" => existing_resource_params,
          "1" => new_resource_params,
        }}

        # It should map the resources, as this format is pretty much the same as an array
        post create_many_api_resources_path(user_organization.id), params: params, as: :json, headers: auth_headers
        expect(response).to be_created
      end
    end
  end

  describe "with multiple resources" do
    include_context "with an author user"

    let(:default_page_size) do
      Rails.configuration.x.resource_api_page_size
    end

    let(:user_org_resource_count) do
      Rails.configuration.x.resource_api_page_size + 1 # to force pagination to occur
    end

    let!(:user_org_resources) do
      create_list(:resource, user_org_resource_count, organization: user_organization, priority_flag: true)
    end

    let(:represented_resource) do
      user_org_resources.first
    end

    let!(:older_resource) do
      create(:resource, organization: user_organization, name: "This should be filtered out using the updated_at_gt filter").tap do |resource|
        resource.update_attribute(:updated_at, 10.days.ago)
      end
    end

    let!(:approved_resource) do
      create(:resource, organization: user_organization, name: "This should be the only response using the with_approved_representations filter").tap do |resource|
        create(:representation, resource: resource, status: "approved")
      end
    end

    before do
      create(:representation, resource: represented_resource, text: 'can search for the term "polyphonic"')
      create(:resource, name: "Current user should not be seeing this due to other org privacy restrictions")
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

      filter = {canonical_id_or_name_or_representations_text_cont_all: "polyphonic"}

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
      expect(json_data[:data].map { |r| r.fetch(:id).to_i }.sort).to eq([older_resource.id, approved_resource.id])
      expect(json_data[:links].keys).to eq(%w[self first]) # Shouldn't return any other (non-matching) resources
    end

    it "POST /organizations/:id/resources/get filtered by source_uri" do
      request_path = get_api_resources_path(user_organization)
      post request_path, headers: auth_headers, params: {filter: {source_uri_eq_any: "#{approved_resource.source_uri} #{older_resource.source_uri}"}}

      expect(json_data[:data].map { |r| r.fetch(:id).to_i }).to eq([approved_resource.id, older_resource.id]) # We order by created_at DESC by default
      expect(json_data[:links].keys).to eq(%w[self first]) # Shouldn't return any other (non-matching) resources
    end
  end

  describe "with a resource" do
    include_context "with an author user"

    let(:resource) do
      create(:resource, canonical_id: "abc123", organization: user_organization)
    end

    it "GET /resources/:id" do
      get api_resource_path(resource.id), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |data|
        expect(data).to have_id(resource.id.to_s)
        expect(data).to have_type("resource")

        expect(data).to have_attribute(:resource_type).with_value(resource.resource_type)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)

        expect(data).to have_relationships(:organization, :representations)
      end
    end

    it "GET /resources/canonical/:id with canonical ID" do
      get api_canonical_resource_path(resource.canonical_id), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |data|
        expect(data).to have_id(resource.id.to_s)
        expect(data).to have_type("resource")

        expect(data).to have_attribute(:resource_type).with_value(resource.resource_type)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)

        expect(data).to have_relationships(:organization, :representations)
      end
    end

    it "GET /resources/:id with an invalid ID" do
      expect {
        get api_resource_path("notanid"), headers: auth_headers
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "without authorization" do
    include_context "with API access headers"

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
