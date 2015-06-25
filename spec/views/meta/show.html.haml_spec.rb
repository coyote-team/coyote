require 'rails_helper'

RSpec.describe "meta/show", type: :view do
  before(:each) do
    @metum = assign(:metum, Metum.create!(
      :title => "Title",
      :instructions => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
  end
end
