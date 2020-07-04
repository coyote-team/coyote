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

  describe "for regular users" do
    let!(:user) { create(:user, :with_membership, password: "password") }

    it "redirects to the user's only organization" do
      expect(user.organizations.count).to eq(1)
      post :create, params: {user: {email: user.email, password: "password"}}
      expect(response).to redirect_to(organization_path(user.organizations.first))
    end

    it "redirects members of multiple organizations to the organization selector" do
      create(:membership, user: user)
      expect(user.organizations.count).to eq(2)
      post :create, params: {user: {email: user.email, password: "password"}}
      expect(response).to redirect_to(organizations_path)
    end

    it "redirects staff members to the organization selector" do
      user.update_attribute(:staff, true)
      expect(user.organizations.count).to eq(1)
      post :create, params: {user: {email: user.email, password: "password"}}
      expect(response).to redirect_to(organizations_path)
    end
  end
end
