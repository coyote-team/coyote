RSpec.describe "Assigning images" do
  let!(:image) { create(:image) } 
  let!(:user) { create(:user) }

  context "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    it "succeeds" do
      click_first_link "Assignments"
      click_first_link "New Assignment"
      expect(page.current_path).to eq(new_assignment_path)

      select(image.title,from: "Image")
      select(user.email,from: "User")

      expect {
        click_button "Create Assignment"
      }.to change(Assignment,:count).from(0).to(1)

      assignment = Assignment.first
      expect(page.current_path).to eq(assignment_path(assignment))

      click_link "Edit"
      select(admin_user.email,from: "User")

      expect {
        click_button "Update Assignment"
        assignment.reload
      }.to change(assignment,:user).from(user).to(admin_user)
    end
  end

  context "when logged-in as a user" do
    include_context "as a logged-in user"

    let(:assignment) { create(:assignment) }

    it "is not allowed" do
      expect(page).not_to have_link("Assignments")
      visit new_assignment_path
      expect(page.current_path).to eq(root_path)

      visit assignment_path(assignment)
      expect(page.current_path).to eq(root_path)

      visit edit_assignment_path(assignment)
      expect(page.current_path).to eq(root_path)
    end
  end
end
