RSpec.shared_context "as a logged-in user" do
  let(:password) { "ABCD1234" }
  let(:user) { create(:user,password: password)  }

  before do
    login(user,password)
  end
end

RSpec.shared_context "as a logged-in admin user" do
  let(:password) { "ABCD1234" }
  let(:admin_user) { create(:user,:admin,password: password)  }

  before do
    login(admin_user,password)
  end
end
