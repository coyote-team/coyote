RSpec.feature "Adding and editing a context" do
  context "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    let(:context_attributes) do
      attributes_for(:context).tap(&:symbolize_keys!)
    end

    it "succeeds" do
      click_link "Contexts"
      click_link "New Context"
      expect(page.current_path).to eq(new_context_path)

      fill_in "Title", with: "Scavenger Hunt"

      expect {
        click_button "Create Context"
      }.to change(Context,:count).from(0).to(1)

      context = Context.first
      expect(page.current_path).to eq(context_path(context))

      click_link "Edit"
      fill_in "Title", with: "Treasure Hunt"

      expect {
        click_button "Update Context"
        context.reload
      }.to change(context,:title).to("Treasure Hunt")
    end
  end
end
