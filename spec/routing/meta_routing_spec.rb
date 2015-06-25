require "rails_helper"

RSpec.describe MetaController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/meta").to route_to("meta#index")
    end

    it "routes to #new" do
      expect(:get => "/meta/new").to route_to("meta#new")
    end

    it "routes to #show" do
      expect(:get => "/meta/1").to route_to("meta#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/meta/1/edit").to route_to("meta#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/meta").to route_to("meta#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/meta/1").to route_to("meta#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/meta/1").to route_to("meta#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/meta/1").to route_to("meta#destroy", :id => "1")
    end

  end
end
