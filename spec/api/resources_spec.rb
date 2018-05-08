RSpec.describe 'Accessing resources' do
  context 'with authorization' do
    include_context 'API editor user'

    let(:resource_group) do
      create(:resource_group, :website, organization: user_organization)
    end

    let(:new_resource_params) do
      attributes_for(:resource).merge(resource_group_id: resource_group.id)
    end

    let(:existing_resource) do
      create(:resource, organization: user_organization)
    end

    scenario 'POST /organizations/:id/resources' do
      expect {
        post api_resources_path(user_organization.id), params: { resource: new_resource_params }, headers: auth_headers
        expect(response).to be_created
      }.to change(user_organization.resources, :count).
        from(0).to(1)

      user_organization.resources.first.tap do |resource|
        expect(resource.title).to eq('Mona Lisa')
        expect(resource.resource_group_title).to eq('website')
      end

      invalid_params = { resource: new_resource_params.except(:identifier) }
      post api_resources_path, params: invalid_params, headers: auth_headers
      expect(response).to be_unprocessable
      expect(json_data).to have_key(:errors)
    end

    scenario 'PATCH /resources/:id' do
      expect {
        patch api_resource_path(existing_resource.id), params: { resource: { title: 'NEWTITLE' } }, headers: auth_headers
        expect(response).to be_success

        existing_resource.reload
      }.to change(existing_resource, :title).
        to('NEWTITLE')

      patch api_resource_path(existing_resource.id), params: { resource: { identifier: nil } }, headers: auth_headers
      expect(response).to be_unprocessable
      expect(json_data).to have_key(:errors)
    end
  end

  context 'with multiple resources' do
    include_context 'API author user'

    let(:default_page_size) do
      Rails.configuration.x.resource_api_page_size
    end

    let(:user_org_resource_count) do
      Rails.configuration.x.resource_api_page_size + 1 # to force pagination to occur
    end

    let!(:user_org_resources) do
      create_list(:resource, user_org_resource_count, organization: user_organization)
    end

    let(:represented_resource) do
      user_org_resources.first
    end

    let!(:representation) do
      create(:representation, resource: represented_resource, text: 'can search for the term "polyphonic"')
    end

    let!(:other_org_resource) do
      create(:resource, title: 'Current user should not be seeing this due to other org privacy restrictions')
    end

    scenario 'GET /organizations/:id/resources' do
      request_path = api_resources_path(user_organization)
      get request_path, headers: auth_headers

      expect(response).to be_success

      expected_link_paths = {
        self:  URI.unescape(request_path),
        first: URI.unescape(api_resources_path(page: { number: 1, size: default_page_size })),
        next:  URI.unescape(api_resources_path(page: { number: 2, size: default_page_size }))
      }

      first_page = json_data.fetch(:data)
      expect(first_page.size).to eq(user_org_resource_count - 1)

      ids = first_page.map { |r| r.fetch(:id).to_i }
      expect(user_org_resources.map(&:id)).to include(*ids)

      link_paths = json_data.fetch(:links).inject({}) do |result, (rel, href)|
        uri = URI.parse(href)
        result.merge(rel.to_sym => uri.request_uri)
      end

      expect(link_paths.size).to eq(expected_link_paths.size)

      expected_link_paths.each do |name, path|
        actual_path = URI.unescape(link_paths.fetch(name))
        expect(actual_path).to eq(path), "Expected '#{name}' link to match '#{path}' but got '#{actual_path}'"
      end

      filter = { identifier_or_title_or_representations_text_cont_all: 'polyphonic' }

      request_path = api_resources_path(user_organization, filter: filter)
      get request_path, headers: auth_headers

      data = json_data.fetch(:data)
      expect(data.size).to eq(1)
    end
  end

  context 'with a resource' do
    include_context 'API author user'

    let(:resource) do
      create(:resource, organization: user_organization)
    end

    scenario 'GET /resources/:id' do
      get api_resource_path(resource), headers: auth_headers
      expect(response).to be_success

      json_data.fetch(:data).tap do |data|
        expect(data).to have_id(resource.id.to_s)
        expect(data).to have_type('resource')

        expect(data).to have_attribute(:resource_type).with_value(resource.resource_type)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)

        expect(data).to have_relationships(:organization, :representations)
      end
    end
  end

  context 'without authorization' do
    include_context 'API access headers'

    let(:resource) { create(:resource) }

    scenario 'returns an error' do
      get api_resources_path(resource.organization_id), headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      get api_resource_path(resource.organization_id, resource.id), headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      post api_resources_path(resource.organization_id), params: { resource: {} }, headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)
    end
  end
end
