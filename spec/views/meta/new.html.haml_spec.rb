require 'rails_helper'

RSpec.describe "meta/new", type: :view do
  before(:each) do
    assign(:metum, Metum.new(
      :title => "MyString",
      :instructions => "MyText"
    ))
  end

  it "renders new metum form" do
    render

    assert_select "form[action=?][method=?]", meta_path, "post" do

      assert_select "input#metum_title[name=?]", "metum[title]"

      assert_select "textarea#metum_instructions[name=?]", "metum[instructions]"
    end
  end
end
