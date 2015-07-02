require 'rails_helper'

RSpec.describe "descriptions/show", type: :view do
  before(:each) do
    @description = assign(:description, Description.create!(
      :image => nil,
      :status => nil,
      :metum => nil,
      :locale => "Locale",
      :text => "MyText",
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Locale/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
