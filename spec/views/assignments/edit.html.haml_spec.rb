require 'rails_helper'

RSpec.describe "assignments/edit", type: :view do
  before(:each) do
    @assignment = assign(:assignment, Assignment.create!(
      :user => nil,
      :image => nil
    ))
  end

  it "renders the edit assignment form" do
    render

    assert_select "form[action=?][method=?]", assignment_path(@assignment), "post" do

      assert_select "input#assignment_user_id[name=?]", "assignment[user_id]"

      assert_select "input#assignment_image_id[name=?]", "assignment[image_id]"
    end
  end
end
