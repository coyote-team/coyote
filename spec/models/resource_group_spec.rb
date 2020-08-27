# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_groups
#
#  id              :integer          not null, primary key
#  default         :boolean          default(FALSE)
#  name            :citext           not null
#  token           :string
#  webhook_uri     :citext
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_name  (organization_id,name) UNIQUE
#  index_resource_groups_on_webhook_uri               (webhook_uri)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => cascade ON UPDATE => cascade
#

RSpec.describe ResourceGroup do
  subject { build(:resource_group) }

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:organization_id) }

  describe "#webhook_uri=" do
    let(:organization) { build_stubbed(:organization, id: 1) }

    before do
      allow(Organization).to receive(:find).with(1).and_return organization
    end

    it "accepts a valid http URI" do
      expect(group_with(webhook_uri: "http://test").errors[:webhook_uri]).to be_empty
    end

    it "accepts a valid https URI" do
      expect(group_with(webhook_uri: "https://test").errors[:webhook_uri]).to be_empty
    end

    it "does not accept a non-http or https URI" do
      expect(group_with(webhook_uri: "ftp://test_host").errors[:webhook_uri]).not_to be_empty
    end

    it "requires AT LEAST a host when provided an http URI" do
      expect(group_with(webhook_uri: "http://").errors[:webhook_uri]).not_to be_empty
    end

    it "requires a host when provided an https URI" do
      expect(group_with(webhook_uri: "https://").errors[:webhook_uri]).not_to be_empty
    end

    def group_with(attributes = {})
      described_class.new(attributes_for(:resource_group, attributes.reverse_merge(organization: organization, organization_id: organization.id))).tap do |resource_group|
        resource_group.valid?
      end
    end
  end
end
