RSpec.feature "Adding and editing a group" do
  context "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    let(:group_attributes) do
      attributes_for(:group).tap(&:symbolize_keys!)
    end

    it "succeeds" do
      click_link "Groups"
      click_link "New Group"
      expect(page.current_path).to eq(new_group_path)

      fill_in "Title", with: "Scavenger Hunt"

      expect {
        click_button "Create Group"
      }.to change(Group,:count).from(0).to(1)

      group = Group.first
      expect(page.current_path).to eq(group_path(group))

      click_link "Edit"
      fill_in "Title", with: "Treasure Hunt"

      expect {
        click_button "Update Group"
        group.reload
      }.to change(group,:title).to("Treasure Hunt")
    end
  end
end
