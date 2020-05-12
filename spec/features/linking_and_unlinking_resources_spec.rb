# frozen_string_literal: true

RSpec.describe "Linking and unlinking resources" do
  include_context "as a logged-in editor user"

  let!(:subject_resource) { create(:resource, name: "Chrysler Building", organization: user_organization) }
  let!(:object_resource) { create(:resource, name: "Picture of Chrysler Building", organization: user_organization) }

  it "succeeds" do
    visit resource_path(subject_resource)

    click_first_link("Create Link to Another Resource")

    expect(page).to have_current_path(new_resource_link_path, ignore_query: true)

    select("hasVersion", from: "Verb")
    select(object_resource.label, from: "Object resource")

    expect {
      click_button("Create Link")
    }.to change(ResourceLink, :count)
      .from(0).to(1)

    resource_link = ResourceLink.first
    expect(page).to have_current_path(resource_link_path(resource_link), ignore_query: true)

    expect(object_resource.object_resource_links.size).to eq(1)
    expect(subject_resource.subject_resource_links.size).to eq(1)

    click_link "Edit"
    expect(page).to have_current_path(edit_resource_link_path(resource_link), ignore_query: true)

    select("hasFormat", from: "Verb")

    expect {
      click_button("Update Link")
      resource_link.reload
    }.to change(resource_link, :verb)
      .from("hasVersion").to("hasFormat")

    expect(page).to have_current_path(resource_link_path(resource_link), ignore_query: true)

    expect {
      click_button("Delete")
    }.to change {
      ResourceLink.exists?(resource_link.id)
    }.from(true).to(false)

    expect(page).to have_current_path(resource_path(subject_resource), ignore_query: true)
  end
end
