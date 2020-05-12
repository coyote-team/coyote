# frozen_string_literal: true

RSpec.describe "Representations" do
  describe "with authentication" do
    include_context "API author user"

    let!(:representation) do
      create(:representation, :approved, ordinality: 0, organization: user_organization).tap do |representation|
        representation.resource.update_attribute(:canonical_id, "abc123")
      end
    end

    let!(:unapproved_representation) do
      create(:representation, :not_approved, organization: user_organization)
    end

    let!(:old_representation) do
      create(:representation, :approved, ordinality: 1, organization: user_organization, resource: representation.resource).tap do |representation|
        representation.update_attribute(:updated_at, 10.days.ago)
      end
    end

    it "GET /resources/:resource_id/representations" do
      get api_representations_path(representation.resource_id), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |data|
        expect(data.size).to eq(2)
        record = data.first

        expect(record).to have_type("representation")
        expect(record).to have_id(representation.id.to_s)
        expect(record).to have_attribute(:text).with_value(representation.text)

        expect(record).to have_relationship(:resource)
      end

      expected_link_paths = {
        self: CGI.unescape(api_representations_path(representation.resource_id)),
      }

      link_paths = jsonapi_link_paths(json_data)

      expect(link_paths).to eq(expected_link_paths)
    end

    it "GET /resources/:resource_id/representations with updated_at_gt filter" do
      get api_representations_path(representation.resource_id), headers: auth_headers
      data = json_data[:data]
      expect(data.size).to eq(2)
      expect(data.map { |datum| datum[:id] }).to eq([representation.id.to_s, old_representation.id.to_s])

      get api_representations_path(representation.resource_id, filter: {updated_at_gt: 9.days.ago}), headers: auth_headers
      data = json_data[:data]
      expect(data.size).to eq(1)
      expect(data.map { |datum| datum[:id] }).to eq([representation.id.to_s])
    end

    it "GET /resources/canonical/:resource_id/representations with canonical id" do
      get api_canonical_representations_path(representation.resource.canonical_id), headers: auth_headers
      expect(response).to be_successful
    end

    it "GET /representations/:id" do
      get api_representation_path(representation.id), headers: auth_headers
      expect(response).to be_successful

      json_data.fetch(:data).tap do |record|
        expect(record).to have_id(representation.id.to_s)
        expect(record).to have_type("representation")
        expect(record).to have_attribute(:text).with_value(representation.text)

        expect(record).to have_relationship(:resource)
      end
    end
  end

  describe "without authentication" do
    include_context "API access headers"

    let!(:representation) do
      create(:representation, :approved)
    end

    it "returns an error" do
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
