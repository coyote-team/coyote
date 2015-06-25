require 'rails_helper'

RSpec.describe "meta/edit", type: :view do
  before(:each) do
    @metum = assign(:metum, Metum.create!(
      :title => "MyString",
      :instructions => "MyText"
    ))
  end

  it "renders the edit metum form" do
    render

    assert_select "form[action=?][method=?]", metum_path(@metum), "post" do

      assert_select "input#metum_title[name=?]", "metum[title]"

      assert_select "textarea#metum_instructions[name=?]", "metum[instructions]"
    end
  end
end
