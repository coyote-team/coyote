# frozen_string_literal: true

class ScavengerHunt::PagesController < ScavengerHunt::ApplicationController
  def show
    render template: "scavenger_hunt/pages/about"
  end
end
