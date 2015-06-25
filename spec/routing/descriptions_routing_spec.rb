require "rails_helper"

RSpec.describe DescriptionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/descriptions").to route_to("descriptions#index")
    end

    it "routes to #new" do
      expect(:get => "/descriptions/new").to route_to("descriptions#new")
    end

    it "routes to #show" do
      expect(:get => "/descriptions/1").to route_to("descriptions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/descriptions/1/edit").to route_to("descriptions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/descriptions").to route_to("descriptions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/descriptions/1").to route_to("descriptions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/descriptions/1").to route_to("descriptions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/descriptions/1").to route_to("descriptions#destroy", :id => "1")
    end

  end
end
