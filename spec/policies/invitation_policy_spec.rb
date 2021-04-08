# frozen_string_literal: true

RSpec.describe InvitationPolicy do
  subject { described_class.new(org_user, Invitation) }

  include_context "with an editor organization user"

  it { is_expected.to forbid_action(:index) }
  it { is_expected.to forbid_action(:show) }
  it { is_expected.to forbid_new_and_create_actions }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy) }

  describe "as an admin" do
    subject do
      described_class.new(org_user, build_stubbed(:invitation, :editor))
    end

    include_context "with an admin organization user"

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "as an admin attempting to mint another admin" do
    subject do
      described_class.new(org_user, build_stubbed(:invitation, :admin))
    end

    include_context "with an admin organization user"

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "as an owner" do
    subject do
      described_class.new(org_user, build_stubbed(:invitation, :owner))
    end

    include_context "with an owner organization user"

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
  end
end
