# frozen_string_literal: true

RSpec.describe UserInvitationService do
  let(:service) { described_class.new(user, organization) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:invitation) { build(:invitation, :editor, recipient_email: recipient_email) }
  let!(:recipient_user) { create(:user, email: "you@example.com") }
  let(:recipient_email) { "you@example.com" }

  it "sets parameters on the passed-in invitation" do
    service.call(invitation)
    expect(invitation.recipient_user).to eq(recipient_user)
    expect(invitation.sender_user).to eq(user)
    expect(invitation.organization).to eq(organization)
  end

  it "creates an organization membership" do
    expect {
      service.call(invitation)
    }.to change(organization.memberships, :count).by(1)
  end

  it "send invitation to existing users" do
    expect {
      service.call(invitation)
    }.to change {
      InvitationMailer.deliveries.size
    }.from(0).to(1)
  end

  describe "when the recipient user is already a member of the organization" do
    before do
      organization.memberships.create!(user: recipient_user)
    end

    it "yields a message" do
      expect { |b|
        service.call(invitation, &b)
      }.to yield_with_args(an_instance_of(String))
    end

    it "does not send an invitation" do
      expect {
        service.call(invitation) {}
      }.not_to change {
        InvitationMailer.deliveries.size
      }.from(0)
    end
  end

  describe "when the recipient user is not already a Coyote user" do
    let(:recipient_email) { "another_user@example.com" }

    it "saves newly-created user records" do
      expect {
        service.call(invitation)
      }.to change {
        User.where(email: "another_user@example.com").any?
      }.from(false).to(true)
    end
  end

  describe "when the invitation is invalid" do
    before do
      invitation.recipient_email = nil
    end

    it "yields a message" do
      expect { |b|
        service.call(invitation, &b)
      }.to yield_with_args(an_instance_of(String))
    end

    it "does not send an invitation" do
      expect {
        service.call(invitation) {}
      }.not_to change {
        InvitationMailer.deliveries.size
      }.from(0)
    end
  end
end
