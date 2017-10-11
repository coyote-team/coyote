module Api
  # Handles calls to /api/v1/resources/
  class ResourcesController < Api::ApplicationController
    resource_description do 
      short 'Anything that can be represented by Coyote'

      desc <<~DESC
        We use the Dublin Core meaning for what a Resource represents: "...a resource is anything that has identity. Familiar examples include an electronic document, an image, 
        a service (e.g., "today's weather report for Los Angeles"), and a collection of other resources. Not all resources are network "retrievable"; e.g., human beings, corporations, and bound books in a library can also be considered resources."
      DESC
    end

    api :GET, '/resources', 'Return a list of resources available to the authenticated user'
    param_group :pagination, Api::ApplicationController
    def index
      resources = current_user.
                  resources.
                  by_id.
                  page(pagination_number).
                  per(pagination_size).
                  without_count

      links = { self: request.url }

      pagination_link_params(resources).each do |rel,link_params|
        link = api_resources_url(page: link_params)
        links[rel] = link
      end

      apply_link_headers(links)

      render({
        jsonapi: resources.to_a,
        include: %i[organization representations],
        links: links
      })
    end

    api :GET, '/resources/:id', 'Return attributes of a particular resource'
    def show
      resource = current_user.resources.find_by!(identifier: params[:id])

      links = { self: request.url }

      apply_link_headers(links)

      render({
        jsonapi: resource,
        include: %i[organization representations],
        links: links
      })
    end
  end
end
