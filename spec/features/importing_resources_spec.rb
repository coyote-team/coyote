# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Importing resources" do
  include_context "as a logged-in admin user"

  before do
    visit organization_path(user_organization)
    click_on user.name
    click_on "Imports"
  end

  it "imports XLSX documents", javascript: true do
    click_on "Start a new import"
    attach_file "Spreadsheet", Rails.root.join("spec", "fixtures", "import", "ch.xlsx")
    click_on "Parse Spreadsheet"
    click_on "provide mappings"

    click_on "Sheet 1"
    select "Resource group", from: "Collection"
    select "Resource group", from: "Exhibit"
    select "Host URI(s)", from: "Link to Source Page"
    select "Name", from: "Object / Image Title"
    select "Canonical ID", from: '"Accession Number"'
    select "Source URI", from: "Source URI"
    select "Alt description text", from: "Alt Description Text"
    select "Long description text", from: "Long Description Text"
    select "Author name", from: "Author"

    click_on "Other Resources"
    select "Resource group", from: "Collection"
    select "Resource group", from: "Exhibit"
    select "Host URI(s)", from: "Link to Source Page"
    select "Name", from: "Object / Image Title"
    select "Canonical ID", from: '"Accession Number"'
    select "Source URI", from: "Source URI"
    select "Alt description text", from: "Alt Description Text"
    select "Long description text", from: "Long Description Text"
    select "Author name", from: "Author"

    click_on "Import"
    expect(page).to have_current_path(import_path(Import.first.id, organization_id: user_organization.to_param))

    # There are 50 unique resources in the spreadsheet, albeit split between two tabs and occassionally duplicated
    expect(Resource.count).to eq(50)
  end

  it "imports CSV documents" do
    click_on "Start a new import"
    attach_file "Spreadsheet", Rails.root.join("spec", "fixtures", "import", "ch.csv")
    click_on "Parse Spreadsheet"
    click_on "provide mappings"

    select "Resource group", from: "Collection"
    select "Resource group", from: "Exhibit"
    select "Host URI(s)", from: "Link to Source Page"
    select "Name", from: "Object / Image Title"
    select "Canonical ID", from: '"Accession Number"'
    select "Source URI", from: "Source URI"
    select "Alt description text", from: "Alt Description Text"
    select "Long description text", from: "Long Description Text"
    select "Author name", from: "Author"

    click_on "Import"
    expect(page).to have_current_path(import_path(Import.first.id, organization_id: user_organization.to_param))

    # There are 50 unique resources in the spreadsheet, albeit split between two tabs and occassionally duplicated
    expect(Resource.count).to eq(50)
  end
end
