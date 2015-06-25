require "rails_helper"

RSpec.describe StatusesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/statuses").to route_to("statuses#index")
    end

    it "routes to #new" do
      expect(:get => "/statuses/new").to route_to("statuses#new")
    end

    it "routes to #show" do
      expect(:get => "/statuses/1").to route_to("statuses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/statuses/1/edit").to route_to("statuses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/statuses").to route_to("statuses#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/statuses/1").to route_to("statuses#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/statuses/1").to route_to("statuses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/statuses/1").to route_to("statuses#destroy", :id => "1")
    end

  end
end
