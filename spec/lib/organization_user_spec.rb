# frozen_string_literal: true

RSpec.describe Coyote::OrganizationUser do
  subject do
    described_class.new(user, organization)
  end

  let(:is_staff) { false }

  let(:user) do
    build_stubbed(:user, id: 10, staff: is_staff)
  end

  let(:organization) do
    build_stubbed(:organization)
  end

  let(:role) { "guest" }

  let(:membership) do
    build_stubbed(:membership, role: role)
  end

  before do
    allow(user).to receive_message_chain(:memberships, :find_by)
      .with(organization: organization)
      .and_return(membership)
  end

  specify { expect(subject.id).to eq(10) }
  specify { expect(subject.role).to eq(:guest) }

  specify { expect(subject).to be_guest }
  specify { expect(subject).not_to be_viewer }
  specify { expect(subject).not_to be_author }
  specify { expect(subject).not_to be_editor }
  specify { expect(subject).not_to be_admin }
  specify { expect(subject).not_to be_owner }
  specify { expect(subject).not_to be_staff }

  specify { expect(subject == user).to eq(true) }
  specify { expect(subject == build_stubbed(:user)).to eq(false) }

  specify { expect(subject.role_rank).to eq(0) }

  describe "as a viewer user" do
    let(:role) { "viewer" }

    specify { expect(subject.role).to eq(:viewer) }
    specify { expect(subject).to be_guest }
    specify { expect(subject).to be_viewer }
    specify { expect(subject).not_to be_author }
    specify { expect(subject).not_to be_editor }
    specify { expect(subject).not_to be_admin }
    specify { expect(subject).not_to be_owner }
    specify { expect(subject).not_to be_staff }
  end

  describe "as a author user" do
    let(:role) { "author" }

    specify { expect(subject.role).to eq(:author) }
    specify { expect(subject).to be_guest }
    specify { expect(subject).to be_viewer }
    specify { expect(subject).to be_author }
    specify { expect(subject).not_to be_editor }
    specify { expect(subject).not_to be_admin }
    specify { expect(subject).not_to be_owner }
    specify { expect(subject).not_to be_staff }
  end

  describe "as a editor user" do
    let(:role) { "editor" }

    specify { expect(subject.role).to eq(:editor) }
    specify { expect(subject).to be_guest }
    specify { expect(subject).to be_viewer }
    specify { expect(subject).to be_author }
    specify { expect(subject).to be_editor }
    specify { expect(subject).not_to be_admin }
    specify { expect(subject).not_to be_owner }
    specify { expect(subject).not_to be_staff }
  end

  describe "as a admin user" do
    let(:role) { "admin" }

    specify { expect(subject.role).to eq(:admin) }
    specify { expect(subject).to be_guest }
    specify { expect(subject).to be_viewer }
    specify { expect(subject).to be_author }
    specify { expect(subject).to be_editor }
    specify { expect(subject).to be_admin }
    specify { expect(subject).not_to be_owner }
    specify { expect(subject).not_to be_staff }
  end

  describe "as an owner user" do
    let(:role) { "owner" }

    specify { expect(subject.role).to eq(:owner) }
    specify { expect(subject).to be_guest }
    specify { expect(subject).to be_viewer }
    specify { expect(subject).to be_author }
    specify { expect(subject).to be_editor }
    specify { expect(subject).to be_admin }
    specify { expect(subject).to be_owner }
    specify { expect(subject).not_to be_staff }
  end

  describe "as a staff user" do
    let(:is_staff) { true }

    specify { expect(subject.role).to eq(:guest) } # note that staff status doesn't change the way the organization views your role
    specify { expect(subject).to be_guest }
    specify { expect(subject).to be_viewer }
    specify { expect(subject).to be_author }
    specify { expect(subject).to be_editor }
    specify { expect(subject).to be_admin }
    specify { expect(subject).to be_owner }
    specify { expect(subject).to be_staff }
    specify { expect(subject.role_rank).to be > Coyote::Membership.role_rank(:owner) }
  end

  describe "with no membership in an organization" do
    before do
      allow(user).to receive_message_chain(:memberships, :find_by)
        .and_return(nil)
    end

    specify { expect(subject.role).to eq(:none) }

    specify { expect(subject).not_to be_guest }
    specify { expect(subject).not_to be_viewer }
    specify { expect(subject).not_to be_author }
    specify { expect(subject).not_to be_editor }
    specify { expect(subject).not_to be_admin }
    specify { expect(subject).not_to be_owner }
    specify { expect(subject).not_to be_staff }
  end
end
