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
#  license_id   :bigint           not null
#  metum_id     :bigint           not null
#  resource_id  :bigint           not null
#
# Indexes
#
#  index_representations_on_author_id    (author_id)
#  index_representations_on_license_id   (license_id)
#  index_representations_on_metum_id     (metum_id)
#  index_representations_on_resource_id  (resource_id)
#  index_representations_on_status       (status)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id) ON DELETE => restrict ON UPDATE => cascade
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
    include_context "webhooks"

    let!(:resource) { create(:resource, resource_groups: [resource_group]) }

    before do
      WebMock.reset!
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "sends webhook notifications when represenations are created (as approved)" do
      representation = create(:representation, resource: resource, status: :approved)
      expect(a_request(:post, resource_group.webhook_uri).with { |req|
        body = JSON.parse(req.body)
        included = body["included"]
        expect(included).to include(have_type("representation").and(have_id(representation.id.to_s)))
      }).to have_been_made
    end

    it "sends webhook notifications when pre-exisitng represenations are marked as approved" do
      representation = create(:representation, resource: resource, status: :ready_to_review)
      representation.update!(status: :approved)
      expect(a_request(:post, resource_group.webhook_uri).with { |req|
        body = JSON.parse(req.body)
        included = body["included"]
        expect(included).to include(have_type("representation").and(have_id(representation.id.to_s)))
      }).to have_been_made
    end

    it "sends webhook notifications when approved represenations are marked as unapproved" do
      representation = create(:representation, resource: resource, status: :approved)
      WebMock.reset!
      representation.update!(status: :not_approved)
      expect(a_request(:post, resource_group.webhook_uri).with { |req|
        body = JSON.parse(req.body)
        included = body["included"]
        expect(included).not_to include(have_type("representation").and(have_id(representation.id.to_s)))
      }).to have_been_made
    end

    it "sends webhook notifications when representations are deleted" do
      representation = create(:representation, resource: resource, status: :approved)
      WebMock.reset!
      representation.destroy
      expect(a_request(:post, resource_group.webhook_uri).with { |req|
        body = JSON.parse(req.body)
        data = body["data"]
        included = body["included"]
        expect(data).to have_attribute(:canonical_id).with_value(resource.canonical_id)
        expect(included).not_to include(have_type("representation").and(have_id(representation.id.to_s)))
      }).to have_been_made
    end

    it "does not send webhook notifications when unapproved representations change" do
      representation = create(:representation, resource: resource, status: :not_approved)
      representation.update!(status: :ready_to_review)
      expect(a_request(:post, resource_group.webhook_uri)).not_to have_been_made
    end

    # rubocop:enable RSpec/MultipleExpectations
  end
end
