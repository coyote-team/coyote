RSpec.describe "Adding and changing a Website" do
  context "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    let(:website_attributes) do
      attributes_for(:website).tap(&:symbolize_keys!)
    end

    it "succeeds" do
      click_link "Websites"
      click_link "New Website"
      expect(page.current_path).to eq(new_website_path)

      fill_in "Title", with: "XYZ Museum"
      fill_in "Url",   with: "http://example.com"

      select("MCA",from: "Strategy")

      expect {
        click_button "Create Website"
      }.to change(Website,:count).from(0).to(1)

      website = Website.first
      expect(page.current_path).to eq(website_path(website))

      click_link "Edit"
      fill_in "Title", with: "ABC Museum"

      expect {
        click_button "Update Website"
        website.reload
      }.to change(website,:title).to("ABC Museum")
    end
  end

  context "when logged-in as a user" do
    include_context "as a logged-in user"

    it "is not allowed" do
      expect(page).not_to have_link("Websites")
      visit new_website_path
      expect(page.current_path).to eq(root_path)

      visit edit_website_path(create(:website))
      expect(page.current_path).to eq(root_path)
    end
  end
end
