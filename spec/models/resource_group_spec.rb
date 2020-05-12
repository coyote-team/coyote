# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_groups
#
#  id              :integer          not null, primary key
#  default         :boolean          default(FALSE)
#  name            :string           not null
#  webhook_uri     :string
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_name  (organization_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => cascade ON UPDATE => cascade
#

RSpec.describe ResourceGroup do
  subject { build(:resource_group) }

  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:organization_id) }

  describe "#webhook_uri=" do
    let(:organization) { build_stubbed(:organization, id: 1) }

    before do
      allow(Organization).to receive(:find).with(1).and_return organization
    end

    it "accepts a valid http URI" do
      expect(described_class.new(attributes(webhook_uri: "http://test"))).to be_valid
    end

    it "accepts a valid https URI" do
      expect(described_class.new(attributes(webhook_uri: "https://test"))).to be_valid
    end

    it "does not accept a non-http or https URI" do
      expect(described_class.new(attributes(webhook_uri: "ftp://test_host"))).not_to be_valid
    end

    it "requires AT LEAST a host when provided an http URI" do
      expect(described_class.new(attributes(webhook_uri: "http://"))).not_to be_valid
    end

    it "requires a host when provided an https URI" do
      expect(described_class.new(attributes(webhook_uri: "https://"))).not_to be_valid
    end

    def attributes(extra = {})
      attributes_for(:resource_group, extra.merge(organization_id: organization.id))
    end
  end
end
