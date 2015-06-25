require 'rails_helper'

RSpec.describe "Meta", type: :request do
  describe "GET /meta" do
    it "works! (now write some real specs)" do
      get meta_path
      expect(response).to have_http_status(200)
    end
  end
end
