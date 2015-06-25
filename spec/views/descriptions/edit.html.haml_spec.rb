require 'rails_helper'

RSpec.describe "descriptions/edit", type: :view do
  before(:each) do
    @description = assign(:description, Description.create!(
      :locale => "MyString",
      :text => "MyText",
      :status => nil,
      :image => nil,
      :metum => nil
    ))
  end

  it "renders the edit description form" do
    render

    assert_select "form[action=?][method=?]", description_path(@description), "post" do

      assert_select "input#description_locale[name=?]", "description[locale]"

      assert_select "textarea#description_text[name=?]", "description[text]"

      assert_select "input#description_status_id[name=?]", "description[status_id]"

      assert_select "input#description_image_id[name=?]", "description[image_id]"

      assert_select "input#description_metum_id[name=?]", "description[metum_id]"
    end
  end
end
