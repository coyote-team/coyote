RSpec.describe 'Representations' do
  context 'with an authentication token' do
    include_context 'API author user'

    let!(:representation) do
      create(:representation,:approved,organization: user_organization)
    end

    skip 'GET /resources/:resource_id/representations' do
      get api_resource_representations_path(representation.resource_identifier), headers: auth_headers
      expect(response).to be_success

      json_data.fetch(:data).tap do |data|
        expect(data.size).to eq(1)
        record = data.first

        expect(record).to have_type('representation')
        expect(record).to have_id(representation.id.to_s)
        expect(record).to have_attribute(:text).with_value(representation.text)

        expect(record).to have_relationship(:resource)
      end

      expected_link_paths = {
        self:  api_resource_representations_path(representation.resource_identifier),
        first: api_resource_representations_path(representation.resource_identifier,page: { number: 1 })
      }

      link_paths = jsonapi_link_paths(json_data)
      
      expect(link_paths).to eq(expected_link_paths)
      expect(link_header_paths(response)).to eq(expected_link_paths)
    end

    skip 'GET /representations/:id' do
      get api_representation_path(representation.id), headers: auth_headers
      expect(response).to be_success

      json_data.fetch(:data).tap do |record|
        expect(record).to have_id(representation.id.to_s)
        expect(record).to have_type('representation')
        expect(record).to have_attribute(:text).with_value(representation.text)

        expect(record).to have_relationship(:resource)
      end
    end
  end

  skip 'without an authentication token' do
    it 'returns an error' do
      get api_representation_path(1)
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      get api_representation_path(1)
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)
    end
  end
end
