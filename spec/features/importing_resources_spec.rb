# frozen_string_literal: true

require "spec_helper"

RSpec.fdescribe "Importing resources" do
  include_context "as a logged-in admin user"

  it "imports XLSX documents", ui: true do
    visit organization_path(user_organization)
    click_on user.name
  end
end
