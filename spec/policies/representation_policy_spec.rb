# frozen_string_literal: true

RSpec.describe RepresentationPolicy do
  subject { described_class.new(org_user, representation) }

  include_context "with a viewer organization user"

  let(:organization) { build_stubbed(:organization) }
  let(:representation) { build_stubbed(:representation) }
  let(:resource) { build_stubbed(:resource) }

  before do
    allow(representation).to receive_messages(author: org_user.user, organization: organization, resource: resource)
  end

  it { is_expected.to permit_action(:index) }
  it { is_expected.to permit_action(:show) }
  it { is_expected.to forbid_new_and_create_actions }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy) }

  describe "as an author working with own content" do
    include_context "with an author organization user"

    let(:organization) { build_stubbed(:organization, allow_authors_to_claim_resources: true) }

    before do
      allow(resource).to receive(:assigned_to?).with(org_user.user).and_return(true)
    end

    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "as an author working with content authored by another user" do
    include_context "with an author organization user"

    before do
      allow(resource).to receive(:assigned_to?).and_return(false)
      allow(representation).to receive(:author).and_return(double(:user))
    end

    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "as an editor" do
    include_context "with an editor organization user"

    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end
end
