module Api
  # Handles calls to /api/v1/
  class RootController < Api::ApplicationController
    api :GET, '/', 'Show API root, with links to available endpoints'
    def show
      render jsonapi: [], links: {
        self: api_root_url,
        resources: api_resources_url
      }
    end
  end
end
