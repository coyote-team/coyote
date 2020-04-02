# frozen_string_literal: true

RSpec.describe RegistrationsController do
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
      patch :update, params: {user: bad_params}
      invitation.reload
    }.not_to change(invitation, :redeemed?)

    expect(response).not_to be_redirect

    expect {
      patch :update, params: {user: user_params}
      invitation.reload
    }.to change(invitation, :redeemed?)
      .from(false).to(true)

    expect(response).to redirect_to(organization_path(invitation.organization))
  end

  describe "with a previously-redeemed invitation" do
    let(:invitation) { create(:invitation, :redeemed) }

    it "basic actions do not succeed" do
      get :new, params: base_params
      expect(response).to redirect_to(new_user_session_path)

      patch :update, params: {user: user_params}
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
