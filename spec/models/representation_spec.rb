# frozen_string_literal: true

# == Schema Information
#
# Table name: representations
#
#  id           :bigint           not null, primary key
#  content_type :string           default("text/plain"), not null
#  content_uri  :string
#  language     :string           not null
#  notes        :text
#  ordinality   :integer
#  status       :enum             default("ready_to_review"), not null
#  text         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  endpoint_id  :bigint           not null
#  license_id   :bigint           not null
#  metum_id     :bigint           not null
#  resource_id  :bigint           not null
#
# Indexes
#
#  index_representations_on_author_id    (author_id)
#  index_representations_on_endpoint_id  (endpoint_id)
#  index_representations_on_license_id   (license_id)
#  index_representations_on_metum_id     (metum_id)
#  index_representations_on_resource_id  (resource_id)
#  index_representations_on_status       (status)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id) ON DELETE => restrict ON UPDATE => cascade
#  fk_rails_...  (endpoint_id => endpoints.id) ON DELETE => cascade
#  fk_rails_...  (license_id => licenses.id) ON DELETE => restrict ON UPDATE => cascade
#  fk_rails_...  (metum_id => meta.id) ON DELETE => restrict ON UPDATE => cascade
#  fk_rails_...  (resource_id => resources.id) ON DELETE => restrict ON UPDATE => cascade
#

RSpec.describe Representation do
  subject { build(:representation) }

  it { is_expected.to validate_presence_of(:language) }

  describe "with text and content URI blank" do
    let(:representation) { build(:representation, text: "", content_uri: "").tap(&:valid?) }

    it "requires a textual representation" do
      expect(representation.errors[:text]).to be_present
    end
  end

  describe "#notify_webhook!" do
    let(:resource_group) { create(:resource_group, webhook_uri: "http://www.example.com/webhook/goes/here") }
    let(:resource) { create(:resource, resource_groups: [resource_group]) }

    before do
      stub_request(:post, resource_group.webhook_uri).to_return(
        body:   "OKAY",
        status: 200,
      )
    end

    around do |example|
      VCR.use_cassette("webhooks", record: :new_episodes) do
        example.run
      end
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "sends webhook notifications when resources are created" do
      create(:representation, resource: resource)
      expect(a_request(:post, resource_group.webhook_uri).with { |req|
        body = JSON.parse(req.body)
        expect(body.dig("data", "attributes", "canonical_id")).to eq(resource.canonical_id)
        # expect(body.dig("data", "attributes", "canonical_id")).to eq(resource.canonical_id)
      }).to have_been_made.times(2)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
