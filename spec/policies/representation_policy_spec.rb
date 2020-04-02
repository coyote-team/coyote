# frozen_string_literal: true

RSpec.describe RepresentationPolicy do
  include_context "viewer organization user"

  subject { described_class.new(org_user, representation) }

  let(:representation) { build_stubbed(:representation) }

  before do
    allow(representation).to receive_messages(author: org_user)
  end

  it { is_expected.to permit_action(:index) }
  it { is_expected.to permit_action(:show) }
  it { is_expected.to forbid_new_and_create_actions }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy) }

  describe "as an author working with own content" do
    include_context "author organization user"

    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "as an author working with content authored by another user" do
    include_context "author organization user"

    before do
      allow(representation).to receive_messages(author: :another_user)
    end

    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "as an editor" do
    include_context "editor organization user"

    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end
end
