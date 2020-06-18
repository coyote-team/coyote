# frozen_string_literal: true

RSpec.describe UsersController do
  let(:organization) { create(:organization) }
  let(:user_of_interest) { create(:user, organization: organization) }

  let(:base_params) do
    {id: user_of_interest.id}
  end

  describe "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      aggregate_failures do
        get :show, params: base_params
        expect(response).to require_login
      end
    end
  end

  describe "as a guest user" do
    include_context "signed-in guest user"

    it "succeeds for critical actions" do
      get :show, params: base_params
      expect(response).to be_successful
    end
  end

  describe "with an invitation" do
    let(:invitation) { create(:invitation) }

    let(:base_params) do
      {token: invitation.token}
    end

    let(:user_params) do
      {email: invitation.recipient_email, password: "12345678", password_confirmation: "12345678", token: invitation.token}
    end

    it "basic actions succeed" do
      expect {
        get :new
      }.to raise_error(ActionController::ParameterMissing)

      get :new, params: base_params
      expect(response).to be_successful

      bad_params = user_params.merge(password_confirmation: "1")

      expect {
        post :create, params: {user: bad_params}
        invitation.reload
      }.not_to change(invitation, :redeemed?)

      expect(response).not_to be_redirect

      expect {
        post :create, params: {user: user_params}
        invitation.reload
      }.to change(invitation, :redeemed?)
        .from(false).to(true)

      expect(response).to redirect_to(organization_path(invitation.organization))
    end

    describe "that has been redeemed" do
      let(:invitation) { create(:invitation, :redeemed) }

      it "basic actions do not succeed" do
        get :new, params: base_params
        expect(response).to require_login

        post :create, params: {user: user_params}
        expect(response).to require_login
      end
    end
  end
end
