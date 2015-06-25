require 'rails_helper'

RSpec.describe "Statuses", type: :request do
  describe "GET /statuses" do
    it "works! (now write some real specs)" do
      get statuses_path
      expect(response).to have_http_status(200)
    end
  end
end
