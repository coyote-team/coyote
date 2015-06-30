require 'rails_helper'

RSpec.describe "images/index", type: :view do
  before(:each) do
    assign(:images, [
      Image.create!(
        :url => "Url",
        :group => nil,
        :website => nil
      ),
      Image.create!(
        :url => "Url",
        :group => nil,
        :website => nil
      )
    ])
  end

  it "renders a list of images" do
    render
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
