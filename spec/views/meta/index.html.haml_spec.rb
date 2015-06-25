require 'rails_helper'

RSpec.describe "meta/index", type: :view do
  before(:each) do
    assign(:meta, [
      Metum.create!(
        :title => "Title",
        :instructions => "MyText"
      ),
      Metum.create!(
        :title => "Title",
        :instructions => "MyText"
      )
    ])
  end

  it "renders a list of meta" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
