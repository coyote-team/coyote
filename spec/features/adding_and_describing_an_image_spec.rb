RSpec.feature "Adding and describing an image" do
  include_context "as a logged-in admin user"

  let!(:website) { create(:website) }
  let!(:group)   { create(:group) }
  let!(:metum)   { create(:metum) }
  let!(:status)  { create(:status) }

  let(:image_attributes) do
    attributes_for(:image).tap(&:symbolize_keys!)
  end

  scenario "succeeds" do |meta|
    click_link "Images"

    first(:link,"New Image").click

    select(website.title,:from => "Website",:match => :first)
    select(group.title,from: "Group",:match => :first)

    fill_in "Canonical ID", with: image_attributes[:canonical_id]
    fill_in "Path",         with: image_attributes[:path]
    fill_in "Title",        with: image_attributes[:title]

    expect {
      click_button("Create Image")
    }.to change(Image,:count).
    from(0).to(1)

    image = Image.first

    expect(page.current_path).to eq(image_path(image))
    expect(page).to have_content(image_attributes[:title])

    click_link "Describe"

    select(metum.title,from: "Metum")
    select("Ready to review",from: "Status")

    text = "This is an installation that viewers are invited to walk inside of. From this viewpoint you are looking through a doorway at a slight distance..."
    fill_in("Text",with: text)

    expect {
      click_button "Create Description"
    }.to change(Description,:count).
    from(0).to(1)

    desc = Description.first
    expect(page.current_path).to eq(description_path(desc))
    expect(page).to have_content(text)
  end
end
