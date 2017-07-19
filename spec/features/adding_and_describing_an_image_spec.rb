RSpec.feature "Adding and describing an image" do
  # CREATE IMAGES, ETC WITH FACTORIES HERE
  include_context "as a logged-in admin user"

  let!(:website) { create(:website) }
  let!(:group)   { create(:group) }

  let(:image_attributes) do
    attributes_for(:image).tap(&:symbolize_keys!)
  end

  scenario "succeeds" do
    click_link "Images"

    first(:link,"New Image").click

    select(website.title,from: "Website")
    select(group.title,from: "Group")

    fill_in "Canonical ID", with: image_attributes[:canonical_id]
    fill_in "Path",         with: image_attributes[:path]
    fill_in "Title",        with: image_attributes[:title]

    expect {
      click_button("Create Image")
    }.to change(Image,:count).
    from(0).to(1)

    expect(page.current_path).to eq(image_path(Image.pluck(:id).first))
    expect(page).to have_content(image_attributes[:title])
  end
end
