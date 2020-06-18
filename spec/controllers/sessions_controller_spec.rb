# frozen_string_literal: true

require "spec_helper"

RSpec.describe SessionsController do
  it "converts outdated Devise credentials to modern has_secure_password credentials" do
    user = create(:user, :devise)
    expect {
      post :create, params: {user: {email: user.email, password: "d3visep@ss"}}
    }.to change {
      user.reload.password_digest
    }.from(nil)
  end
end
