# == Schema Information
#
# Table name: invitations
#
#  id                :integer          not null, primary key
#  recipient_email   :string           not null
#  token             :string           not null
#  sender_user_id    :integer          not null
#  recipient_user_id :integer          not null
#  organization_id   :integer          not null
#  redeemed_at       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  role              :enum             default("viewer"), not null
#
# Indexes

#  index_invitations_on_organization_id            (organization_id)
#  index_invitations_on_recipient_email_and_token  (recipient_email,token)
#  index_invitations_on_recipient_user_id          (recipient_user_id)
#  index_invitations_on_sender_user_id             (sender_user_id)
#

RSpec.describe InvitationsController do
  let(:organization) { create(:organization) }

  let(:base_params) do
    { organization_id: organization.id }
  end

  let(:creation_params) do
    base_params.merge(invitation: { recipient_email: 'me@example.com', role: 'author' })
  end

  context "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :new, params: base_params
        expect(response).to redirect_to(new_user_session_url)

        post :create, params: creation_params
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "as an admin" do
    include_context "signed-in admin user"

    it "succeeds for basic actions" do
      get :new, params: base_params
      expect(response).to be_success

      expect {
        post :create, params: creation_params
        expect(response).to be_redirect
      }.to change(Invitation,:count).
        from(0).to(1)

      new_user = Invitation.first.recipient_user
      
      expect(Membership.exists?(user: new_user,organization: organization,role: 'author')).to be true

      expect {
        post :create, params: creation_params
      }.not_to change(Invitation,:count)

      expect(response).to be_success 
    end
  end
end
