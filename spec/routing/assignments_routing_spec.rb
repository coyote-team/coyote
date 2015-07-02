require "rails_helper"

RSpec.describe AssignmentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/assignments").to route_to("assignments#index")
    end

    it "routes to #new" do
      expect(:get => "/assignments/new").to route_to("assignments#new")
    end

    it "routes to #show" do
      expect(:get => "/assignments/1").to route_to("assignments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/assignments/1/edit").to route_to("assignments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/assignments").to route_to("assignments#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/assignments/1").to route_to("assignments#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/assignments/1").to route_to("assignments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/assignments/1").to route_to("assignments#destroy", :id => "1")
    end

  end
end
