RSpec.describe "Viewing static pages" do
  scenario "works for the root path" do
    visit root_path
    expect(current_path).to eq("/")
  end

  scenario "works for the support page" do
    visit support_path
    expect(current_path).to eq("/support")
  end
end
