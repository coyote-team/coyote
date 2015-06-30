require 'rails_helper'

RSpec.describe "images/edit", type: :view do
  before(:each) do
    @image = assign(:image, Image.create!(
      :url => "MyString",
      :group => nil,
      :website => nil
    ))
  end

  it "renders the edit image form" do
    render

    assert_select "form[action=?][method=?]", image_path(@image), "post" do

      assert_select "input#image_url[name=?]", "image[url]"

      assert_select "input#image_group_id[name=?]", "image[group_id]"

      assert_select "input#image_website_id[name=?]", "image[website_id]"
    end
  end
end
