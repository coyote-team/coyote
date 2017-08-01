RSpec.describe ApplicationHelper do
  let(:current_user) { build_stubbed(:user,first_name: "Hal") }

  subject do
    Struct.new(:current_user) {
      include ApplicationHelper
    }.new(current_user)
  end

  context "#welcome_message" do
    it "greets a logged-in user" do
      expect(subject.welcome_message).to match(/Welcome.+Hal/)
    end

    it "greets non-logged-in users" do
      assign(:current_user,nil)
      expect(subject.welcome_message).to match(/Welcome/)
    end
  end
end
