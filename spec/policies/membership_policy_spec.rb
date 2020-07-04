# frozen_string_literal: true

RSpec.describe MembershipPolicy do
  subject { described_class.new(org_user, record) }

  let(:org_user) do
    double(:organization_user, admin?: false, editor?: true, id: 2, role_rank: 1, owner?: false, staff?: false)
  end

  let(:record) do
    double(:record, user_id: 1, class: Membership, role_rank: 0)
  end

  let(:scope) { double(:scope) }

  it { is_expected.to forbid_new_and_create_actions }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to permit_action(:show) }
  it { is_expected.to permit_action(:index) }
  it { is_expected.to forbid_action(:destroy) }

  specify { expect(subject.scope).to eq(Membership) }

  describe "as an admin" do
    before do
      allow(org_user).to receive_messages(admin?: true)
    end

    describe "when accessing another user's membership" do
      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to permit_action(:destroy) }
    end

    describe "when accessing the membership of a role with the same rank" do
      before do
        allow(record).to receive_messages(role_rank: org_user.role_rank)
      end

      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action(:destroy) }
    end

    describe "when accessing the membership of a role with a higher rank" do
      before do
        allow(record).to receive_messages(role_rank: org_user.role_rank + 1)
      end

      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  describe "as an admin attempting to change self membership" do
    before do
      allow(org_user).to receive_messages(admin?: true, id: 1)
    end

    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "as an editor editing someone else's membership" do
    before do
      allow(org_user).to receive_messages(admin?: false, editor?: true, id: 2)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "as a staff member attempting to change self membership" do
    before do
      allow(org_user).to receive_messages(owner?: true, staff?: true, id: 1)
    end

    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end
end
