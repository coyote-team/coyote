RSpec.describe "Assigning images" do
  context "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    let!(:image) do 
      create(:image,organization: user_organization)
    end

    let!(:other_user) do 
      create(:user,organization: user_organization) 
    end

    it "succeeds" do
      click_first_link "Assignments"
      click_first_link "New Assignment"

      expect(page.current_path).to eq(new_organization_assignment_path(user_organization))

      select(image.title,from: "Image")
      select(user.email,from: "User")

      expect {
        click_button "Create Assignment"
      }.to change(user_organization.assignments,:count).from(0).to(1)

      assignment = user_organization.assignments.first
      expect(page.current_path).to eq(organization_assignment_path(user_organization,assignment))

      click_link "Edit"
      select(other_user.email,from: "User")

      expect {
        click_button "Update Assignment"
        assignment.reload
      }.to change(assignment,:user).from(user).to(other_user)
    end
  end

  context "when logged-in as a user" do
    include_context "as a logged-in user"

    let!(:image) do 
      create(:image,organization: user_organization)  
    end

    let(:assignment) do 
      create(:assignment,image: image)
    end

    it "is not allowed" do
      expect(page).not_to have_link("Assignments")
      
      visit new_organization_assignment_path(user_organization)
      expect(page.current_path).to eq(organization_path(user_organization))

      visit organization_assignment_path(user_organization,assignment)
      expect(page.current_path).to eq(organization_path(user_organization))

      visit edit_organization_assignment_path(user_organization,assignment)
      expect(page.current_path).to eq(organization_path(user_organization))
    end
  end
end
