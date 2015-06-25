require 'rails_helper'

RSpec.describe "websites/new", type: :view do
  before(:each) do
    assign(:website, Website.new(
      :title => "MyString",
      :url => "MyString"
    ))
  end

  it "renders new website form" do
    render

    assert_select "form[action=?][method=?]", websites_path, "post" do

      assert_select "input#website_title[name=?]", "website[title]"

      assert_select "input#website_url[name=?]", "website[url]"
    end
  end
end
