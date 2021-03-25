# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_groups
#
#  id                   :integer          not null, primary key
#  auto_match_host_uris :string           default([]), not null, is an Array
#  default              :boolean          default(FALSE)
#  name                 :citext           not null
#  token                :string
#  webhook_uri          :citext
#  created_at           :datetime
#  updated_at           :datetime
#  organization_id      :integer          not null
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

  describe "#match_resources!" do
    let(:organization) { create(:organization) }
    let(:default_resource_group) { organization.resource_groups.default.first }
    let!(:resource_group) {
      create(
        :resource_group,
        auto_match_host_uris: '
https://www.example.com/\d\d\d\d/\d\d/\d+/.+
https://www.example.com/blog/.*
',
        organization:         organization,
      )
    }

    it "does notthing with blank URIs" do
      expect {
        create(:resource_group, auto_match_host_uris: "", organization: organization).match_resources!
      }.not_to change(ResourceGroupResource, :count)
    end

    it "finds resources with matching regex segments" do
      # Nice, vanilla resources without any abnormal groups
      resource_1 = create(:resource, organization: organization, host_uris: "https://www.example.com/0000/12/20583/whatever")
      resource_2 = create(:resource, organization: organization, host_uris: "http://www.example.com/blog/things/are/awesome,https://www.example.com/0000/12/20583/whatever")
      resource_3 = create(:resource, organization: organization, host_uris: "http://www.example.com/blog-copy/things/are/awesome,https://www.example.com/a000/12/20583/whatever")

      # Match some stuff
      resource_group.match_resources!

      # They should both have matched
      expect(resource_1.resource_groups.reload).to eq([
        default_resource_group,
        resource_group,
      ])
      expect(resource_2.resource_groups.reload).to eq([
        default_resource_group,
        resource_group,
      ])
      expect(resource_3.resource_groups.reload).to eq([
        default_resource_group,
      ])
    end

    it "doesn't duplicate resource groups" do
      resource = create(
        :resource,
        organization:    organization,
        host_uris:       "https://www.example.com/0000/12/20583/whatever",
        resource_groups: [default_resource_group, resource_group],
      )
      expect(resource.resource_groups).to eq([default_resource_group, resource_group])
      resource_group.match_resources!
      expect(resource.resource_groups.reload).to eq([default_resource_group, resource_group])
    end
  end

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
