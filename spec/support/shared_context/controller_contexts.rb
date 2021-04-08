# frozen_string_literal: true

# TODO: Combine this with `logged_in_user_contexts`
RSpec.shared_context "with no user signed in" do
  before do
    sign_out
  end
end

Coyote::Membership.each_role do |_, role_name|
  RSpec.shared_context "with a signed-in #{role_name} user" do
    # Assumes that in your spec you will define the organization
    let(:user) { create(:user) }

    let!(:user_membership) do
      create(:membership, role_name, user: user, organization: organization)
    end

    before do
      sign_in(user)
    end
  end
end

RSpec.shared_context "with a signed-in staff user" do
  let(:user) do
    create(:user, :staff, organization: organization)
  end

  before do
    sign_in(user)
  end
end
