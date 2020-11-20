# frozen_string_literal: true

module Api
  # Handles API calls for Meta
  class MetaController < Api::ApplicationController
    def index
      render({
        jsonapi: current_organization.meta,
      })
    end
  end
end
