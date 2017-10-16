RSpec.describe 'Authenticated user accessing resources' do
  include_context 'API author user'

  let(:context) do
    create(:context,:website,organization: user_organization) 
  end

  let(:new_resource_params) do
    attributes_for(:resource).merge(context_id: context.id)
  end

  skip 'POST /organizations/:id/resources' do
    expect {
      post api_resources_path(user_organization.id), params: { resource: new_resource_params }, headers: auth_headers
    }.to change(user_organization.resources,:count).
    from(0).to(1)

    user_organization.resources.first.tap do |resource|
      expect(resource.title).to eq('Mona Lisa')
      expect(resource.context_title).to eq('website')
    end

    invalid_params = { resource: new_resource_params.except(:identifier) }
    post api_resources_path, params: invalid_params, headers: auth_headers
    expect(response).to be_unprocessable
    expect(json_data).to have_key(:errors)
  end

  skip 'GET /organizations/:id/resources without pagination' do
    resource = create(:resource,organization: user_organization)

    get api_resources_path(user_organization.id), headers: auth_headers
    expect(response).to be_success

    json_data.fetch(:data).tap do |data|
      expect(data.size).to eq(1)
      record = data.first

      expect(record).to have_id(resource.identifier)
      expect(record).to have_type('resource')

      expect(record).to have_attribute(:resource_type).with_value(resource.resource_type)
      expect(record).to have_attribute(:canonical_id).with_value(resource.canonical_id)
      expect(record).to have_attribute(:canonical_id).with_value(resource.canonical_id)

      expect(record).to have_relationships(:organization,:representations)
    end

    json_data.fetch(:included).tap do |included|
      expect(included.size).to eq(1)
      record = included.first
      expect(record).to have_id(user_organization.id.to_s)
      expect(record).to have_type('organization')
    end

    expected_link_paths = {
      self: api_resources_path,
      first: api_resources_path(page: { number: 1 })
    }

    link_paths = jsonapi_link_paths(json_data)

    expect(link_paths).to eq(expected_link_paths)
    expect(link_header_paths(response)).to eq(expected_link_paths)
  end

  skip 'with multiple pages' do
    let(:user_org_resource_count) do
      Rails.configuration.x.resource_api_page_size + 1 # to force pagination to occur
    end

    let!(:user_org_resources) do 
      create_list(:resource,user_org_resource_count,organization: user_organization)
    end

    let!(:other_org_resource) do
      create(:resource,title: 'Current user should not be seeing this due to other org privacy restrictions')
    end

    scenario 'GET /resources' do
      get api_resources_path, headers: auth_headers
      expect(response).to be_success

      expected_link_paths = {
        self: api_resources_path,
        first: api_resources_path(page: { number: 1 }),
        next: api_resources_path(page: { number: 2 })
      }

      expect(link_header_paths(response)).to eq(expected_link_paths)

      first_page = json_data.fetch(:data)
      expect(first_page.size).to eq(user_org_resource_count - 1)

      identifiers = first_page.map { |r| r.fetch(:id) }
      expect(user_org_resources.map(&:identifier)).to include(*identifiers)

      link_paths = json_data.fetch(:links).inject({}) do |result,(rel,href)|
        uri = URI.parse(href)
        result.merge(rel.to_sym => uri.request_uri)
      end

      expect(link_paths).to eq(expected_link_paths)
    end

    scenario 'GET /resources/:id' do
      get api_resource_path(resource.identifier), headers: auth_headers
      expect(response).to be_success

      json_data.fetch(:data).tap do |data|
        expect(data).to have_id(resource.identifier)
        expect(data).to have_type('resource')

        expect(data).to have_attribute(:resource_type).with_value(resource.resource_type)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)

        expect(data).to have_relationships(:organization,:representations)
      end
    end
  end
end

RSpec.describe 'Unauthenticated user accessing resources' do
  let(:resource) { create(:resource) }

  skip 'returns an error' do
    get api_resources_path(resource.organization_id), headers: api_headers
    expect(response).to be_unauthorized
    expect(json_data).to have_key(:errors)

    get api_resource_path(resource.organization_id,resource.id), headers: api_headers
    expect(response).to be_unauthorized
    expect(json_data).to have_key(:errors)

    post api_resources_path(resource.organization_id), params: { resource: {} }, headers: api_headers
    expect(response).to be_unauthorized
    expect(json_data).to have_key(:errors)
  end
end
