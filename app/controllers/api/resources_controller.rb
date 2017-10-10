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

    api :GET, '/', 'Show list of resources available to the authenticated user'
    param :'page[number]', Integer
    param :'page[size]', Integer, desc: "How many records to return per page, (defaults to #{Resource.default_per_page} records)"
    def index
      page_number = page_params[:number]
      page_size = page_params[:size]

      resources = current_user.
                  resources.
                  by_id.
                  page(page_number).
                  per(page_size).
                  without_count

      first_page_params = page_params.dup
      first_page_params[:number] = 1 # Kaminari numbers pages from 1 instead of 0

      links = { 
        self: request.url,
        first:  api_resources_url(page: first_page_params)
      }

      unless resources.first_page?
        prev_page_params = page_params.dup
        prev_page_params[:number] = resources.prev_page
        links[:prev] = api_resources_url(page: prev_page_params)
      end
      
      unless resources.last_page?
        next_page_params = page_params.dup
        next_page_params[:number] = resources.next_page
        links[:next] = api_resources_url(page: next_page_params)
      end

      link_headers = links.inject([]) do |result,(rel,href)|
        result << %(<#{href}>; rel="#{rel}")
      end

      headers['Link'] = link_headers.join(', ')
      
      render({
        jsonapi: resources.to_a,
        include: %i[organization representations],
        links: links
      })
    end

    private

    def page_params
      params.fetch(:page,{}).permit(:number,:size)
    end
  end
end
