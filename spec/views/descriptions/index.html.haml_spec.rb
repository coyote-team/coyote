require 'rails_helper'

RSpec.describe "descriptions/index", type: :view do
  before(:each) do
    assign(:descriptions, [
      Description.create!(
        :locale => "Locale",
        :text => "MyText",
        :status => nil,
        :image => nil,
        :metum => nil
      ),
      Description.create!(
        :locale => "Locale",
        :text => "MyText",
        :status => nil,
        :image => nil,
        :metum => nil
      )
    ])
  end

  it "renders a list of descriptions" do
    render
    assert_select "tr>td", :text => "Locale".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
