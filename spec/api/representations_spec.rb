RSpec.describe 'Representations' do
  context 'with authentication' do
    include_context 'API author user'

    let!(:representation) do
      create(:representation, :approved, organization: user_organization)
    end

    let!(:unapproved_representation) do
      create(:representation, :not_approved, organization: user_organization)
    end

    let!(:old_representation) do
      create(:representation, :approved, organization: user_organization, resource: representation.resource).tap do |representation|
        representation.update_attribute(:updated_at, 10.days.ago)
      end
    end

    scenario 'GET /resources/:resource_id/representations' do
      get api_representations_path(representation.resource_identifier), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |data|
        expect(data.size).to eq(2)
        record = data.first

        expect(record).to have_type('representation')
        expect(record).to have_id(representation.id.to_s)
        expect(record).to have_attribute(:text).with_value(representation.text)

        expect(record).to have_relationship(:resource)
      end

      expected_link_paths = {
        self:  URI.unescape(api_representations_path(representation.resource_identifier))
      }

      link_paths = jsonapi_link_paths(json_data)

      expect(link_paths).to eq(expected_link_paths)
    end

    scenario 'GET /resources/:resource_id/representations with updated_at_gt filter' do
      get api_representations_path(representation.resource_identifier), headers: auth_headers
      data = json_data[:data]
      expect(data.size).to eq(2)
      expect(data.map {|datum| datum[:id] }).to eq([representation.id.to_s, old_representation.id.to_s])

      get api_representations_path(representation.resource_identifier, filter: { updated_at_gt: 9.days.ago }), headers: auth_headers
      data = json_data[:data]
      expect(data.size).to eq(1)
      expect(data.map {|datum| datum[:id] }).to eq([representation.id.to_s])
    end

    scenario 'GET /resources/:resource_id/representations with canonical id' do
      get api_representations_path(representation.resource.canonical_id), headers: auth_headers
      expect(response).to be_successful
    end

    scenario 'GET /representations/:id' do
      get api_representation_path(representation.id), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |record|
        expect(record).to have_id(representation.id.to_s)
        expect(record).to have_type('representation')
        expect(record).to have_attribute(:text).with_value(representation.text)

        expect(record).to have_relationship(:resource)
      end
    end
  end

  context 'without authentication' do
    include_context 'API access headers'

    let!(:representation) do
      create(:representation, :approved)
    end

    scenario 'returns an error' do
      get api_representations_path(representation.resource), headers: api_headers

      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      get api_representation_path(1), headers: api_headers

      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)

      get api_representation_path(1), headers: api_headers
      expect(response).to be_unauthorized
      expect(json_data).to have_key(:errors)
    end
  end
end
