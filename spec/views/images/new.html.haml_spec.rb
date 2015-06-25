require 'rails_helper'

RSpec.describe "images/new", type: :view do
  before(:each) do
    assign(:image, Image.new(
      :url => "MyString",
      :website => nil
    ))
  end

  it "renders new image form" do
    render

    assert_select "form[action=?][method=?]", images_path, "post" do

      assert_select "input#image_url[name=?]", "image[url]"

      assert_select "input#image_website_id[name=?]", "image[website_id]"
    end
  end
end
