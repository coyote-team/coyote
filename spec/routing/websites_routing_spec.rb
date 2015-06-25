require "rails_helper"

RSpec.describe WebsitesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/websites").to route_to("websites#index")
    end

    it "routes to #new" do
      expect(:get => "/websites/new").to route_to("websites#new")
    end

    it "routes to #show" do
      expect(:get => "/websites/1").to route_to("websites#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/websites/1/edit").to route_to("websites#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/websites").to route_to("websites#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/websites/1").to route_to("websites#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/websites/1").to route_to("websites#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/websites/1").to route_to("websites#destroy", :id => "1")
    end

  end
end
