RSpec.describe 'Resources' do
  context 'with an authentication token' do
    include_context 'API author user'

    context 'without pagination' do
      let!(:resource) do
        create(:resource,organization: user_organization)
      end

      # TODO: rewrite these using https://github.com/jsonapi-rb/jsonapi-rspec
      scenario 'GET /resources' do
        get api_resources_path, headers: auth_headers
        expect(response).to be_success

        data = json_data.fetch(:data)
        expect(data.size).to eq(1)

        api_resource = data.first
        expect(api_resource.fetch(:id)).to eq(resource.identifier)
        expect(api_resource.fetch(:type)).to eq('resource')

        api_resource.fetch(:attributes).tap do |attrib|
          expect(attrib.fetch(:resource_type)).to eq(resource.resource_type)
          expect(attrib.fetch(:canonical_id)).to eq(resource.canonical_id)
        end

        api_resource.fetch(:relationships).tap do |relations|
          expect(relations.fetch(:organization)).to be_present
          expect(relations.fetch(:organization)).to be_an_instance_of(Hash)

          expect(relations.fetch(:representations)).to be_present
          expect(relations.fetch(:representations)).to be_an_instance_of(Hash)
        end

        included = json_data.fetch(:included)
        expect(included.size).to eq(1)

        included.first.tap do |o|
          expect(o.fetch(:id)).to eq(user_organization.id.to_s)
          expect(o.fetch(:type)).to eq('organization')
          expect(o.fetch(:attributes).fetch(:title)).to eq(user_organization.title)
        end

        links = json_data.fetch(:links)
        expect(links.size).to eq(2)

        self_path = URI.parse(links.fetch(:self)).request_uri
        expect(self_path).to eq(api_resources_path)

        first_path = URI.parse(links.fetch(:first)).request_uri
        expect(first_path).to eq(api_resources_path(page: { number: 1 }))

        jsonapi = json_data.fetch(:jsonapi)
        expect(jsonapi).to be_an_instance_of(Hash)

        expected_link_paths = {
          self: api_resources_path,
          first: api_resources_path(page: { number: 1 })
        }
        
        expect(link_header_paths(response)).to eq(expected_link_paths)
      end
    end
  end

  context 'with multiple pages' do
    include_context 'API author user'

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
  end

  context 'without an authentication token' do
    it 'returns an error' do
      get api_resources_path
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)
    end
  end
end
