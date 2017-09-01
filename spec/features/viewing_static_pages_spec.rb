RSpec.describe "Viewing static pages" do
  scenario "succeeds" do
    HighVoltage.page_ids.each do |page|
      visit page_path(page)
      expect(current_path).to eq("/#{page}")
    end
  end
end
