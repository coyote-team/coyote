# frozen_string_literal: true

RSpec.describe Staff::PasswordResetsController do
  let(:resetable_user) { create(:user) }
  let(:organization) { create(:organization) }

  let(:user_params) do
    {user_id: resetable_user.id}
  end

  describe "as a signed-out user" do
    include_context "signed-out user"

    it "requires login for all actions" do
      post :create, params: user_params
      expect(response).to require_login
    end
  end

  describe "as a signed-in owner" do
    include_context "signed-in owner user"

    it "requires user to be a staff member for all actions" do
      expect {
        post :create, params: user_params
      }.to raise_error(Coyote::SecurityError)
    end
  end

  describe "as a staff member" do
    include_context "signed-in staff user"

    before do
      ActionMailer::Base.deliveries.clear
    end

    it "succeeds for all actions involving organization-owned contexts" do
      expect {
        post :create, params: user_params
      }.to change(ActionMailer::Base.deliveries, :count)
        .from(0).to(1)

      resetable_user.reload
      expect(resetable_user.password_resets.first).to be_present
      expect(response).to redirect_to(staff_user_url(resetable_user))
    end
  end
end
