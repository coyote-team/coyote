RSpec.describe 'Resources' do
  context 'with an authentication token' do
    include_context 'API author user'

    context 'without pagination' do
      let!(:resource) do
        create(:resource,organization: user_organization)
      end

      # TODO: rewrite these using https://github.com/jsonapi-rb/jsonapi-rspec
      scenario 'GET /resources', :show_in_doc do
        get api_resources_path, headers: auth_headers
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

      scenario 'GET /resources/:id',:show_in_doc do
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

    scenario 'GET /resources', :show_in_doc do
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
