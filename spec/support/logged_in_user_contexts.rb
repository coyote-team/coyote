RSpec.shared_context "as a logged-in user" do
  let(:password) { "ABCD1234" }
  let(:user) { create(:user,:with_membership,password: password)  }

  before do
    login(user,password)
  end
end

%i[viewer author editor admin super_admin staff].each do |role_name|
  RSpec.shared_context "as a logged-in #{role_name} user" do
    let(:password) { "ABCD1234" }
    let(:user) { create(:user,:with_membership,role_name,password: password)  }

    before do
      login(user,password)
    end
  end
end
