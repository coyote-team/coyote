# frozen_string_literal: true

module Api
  # Handles calls to /api/v1/profile
  class UsersController < Api::ApplicationController
    resource_description do
      short "The user record"
      formats %w[json]
    end

    api :GET, "profile", "Return the authenticated user and their organization memberships"
    def show
      render jsonapi: current_user, include: %i[organizations]
    end
  end
end
