require 'rails_helper'

RSpec.describe "websites/edit", type: :view do
  before(:each) do
    @website = assign(:website, Website.create!(
      :title => "MyString",
      :url => "MyString"
    ))
  end

  it "renders the edit website form" do
    render

    assert_select "form[action=?][method=?]", website_path(@website), "post" do

      assert_select "input#website_title[name=?]", "website[title]"

      assert_select "input#website_url[name=?]", "website[url]"
    end
  end
end
