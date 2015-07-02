require 'rails_helper'

RSpec.describe "assignments/new", type: :view do
  before(:each) do
    assign(:assignment, Assignment.new(
      :user => nil,
      :image => nil
    ))
  end

  it "renders new assignment form" do
    render

    assert_select "form[action=?][method=?]", assignments_path, "post" do

      assert_select "input#assignment_user_id[name=?]", "assignment[user_id]"

      assert_select "input#assignment_image_id[name=?]", "assignment[image_id]"
    end
  end
end
