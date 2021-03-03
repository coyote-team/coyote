# frozen_string_literal: true

RSpec.shared_context "with a logged-in user" do
  let(:password) { "ABCD1234" }
  let(:user_organization) { create(:organization) }
  let(:user) do
    create(:user, organization: user_organization, password: password)
  end

  before do
    login(user, password)
  end
end

%i[viewer author editor admin super_admin].each do |role_name|
  RSpec.shared_context "with a logged-in #{role_name} user" do
    let(:password) { "ABCD1234" }
    let(:user_organization) { create(:organization) }
    let(:user) do
      create(:user, organization: user_organization, role: role_name, password: password)
    end

    before do
      login(user, password)
    end
  end
end

RSpec.shared_context "with a logged-in staff user" do
  let(:password) { "ABCD1234" }
  let(:user_organization) { create(:organization) }
  let(:user) do
    create(:user, :staff, organization: user_organization, password: password)
  end

  before do
    login(user, password)
  end
end
