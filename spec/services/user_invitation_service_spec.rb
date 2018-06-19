RSpec.describe UserInvitationService do
  let(:user) { build_stubbed(:user) }
  let(:organization) { build_stubbed(:organization) }
  let(:invitation) { build_stubbed(:invitation, :editor, recipient_email: 'you@example.com') }
  let(:recipient_user) { build_stubbed(:user, email: 'you@example.com') }

  subject do
    UserInvitationService.new(user, organization)
  end

  before do
    allow(User).
      to receive_message_chain(:create_with, :find_or_initialize_by).
      with(email: 'you@example.com').
      and_return(recipient_user)

    allow(organization).to receive_message_chain(:users, :exists?).
      with(recipient_user.id).
      and_return(false)

    allow(Invitation).to receive(:transaction).and_yield

    allow(recipient_user).to receive_messages(save!: nil)
    allow(invitation).to receive_messages(save: true)
    allow(organization).to receive_message_chain(:memberships, :find_or_create_by!)

    allow(InvitationMailer).to receive_message_chain(:new_user, :deliver_now)
    allow(InvitationMailer).to receive_message_chain(:existing_user, :deliver_now)
  end

  it 'sets parameters on the passed-in invitation' do
    aggregate_failures do
      expect(invitation).to receive(:recipient_user=).with(recipient_user)
      expect(invitation).to receive(:sender_user=).with(user)
      expect(invitation).to receive(:organization=).with(organization)
    end

    subject.call(invitation)
  end

  it 'creates an organization membership' do
    expect(organization).to receive_message_chain(:memberships, :find_or_create_by!).
      with(user: recipient_user, role: 'editor')

    subject.call(invitation)
  end

  it 'send invitation to existing users' do
    expect(InvitationMailer).to receive_message_chain(:existing_user, :deliver_now)
    subject.call(invitation)
  end

  context 'when the recipient user is already a member of the organization' do
    before do
      allow(organization).
        to receive_message_chain(:users, :exists?).
        and_return(true)
    end

    it 'yields a message' do
      expect { |b|
        subject.call(invitation, &b)
      }.to yield_with_args(an_instance_of(String))
    end

    it 'does not send an invitation' do
      expect(InvitationMailer).not_to receive(:existing_user)
      expect(InvitationMailer).not_to receive(:new_user)

      subject.call(invitation) {}
    end
  end

  context 'when the recipient user is not already a Coyote user' do
    before do
      allow(recipient_user).to receive_messages(new_record?: true)
    end

    it 'saves newly-created user records' do
      expect(recipient_user).to receive(:save!)
      subject.call(invitation)
    end
  end

  context 'when the invitation is invalid' do
    before do
      allow(invitation).to receive_messages(save: false)
    end

    it 'yields a message' do
      expect { |b|
        subject.call(invitation, &b)
      }.to yield_with_args(an_instance_of(String))
    end

    it 'does not send an invitation' do
      expect(InvitationMailer).not_to receive(:existing_user)
      expect(InvitationMailer).not_to receive(:new_user)

      subject.call(invitation) {}
    end
  end
end
