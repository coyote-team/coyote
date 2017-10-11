module Api
  # Handles API calls for Representations
  class RepresentationsController < Api::ApplicationController
    resource_description do 
      short 'Complementary and alternative sensory impressions of a Resource'

      desc <<~DESC
        For a visual resource such as a painting, Coyote can store Representations such as textual descriptions
        or audio recordings of a speaker describing the painting.
      DESC
    end

    api :GET, '/resources/:resource_id/representations', 'Return list of representations for a particular resource ID'
    param :resource_id, String, 'Identifies the resource being represented'
    param_group :pagination, Api::ApplicationController
    def index
      resource = current_user.resources.find_by!(identifier: params[:resource_id])

      representations = resource.
                        approved_representations.
                        by_id.
                        page(pagination_number).
                        per(pagination_size).
                        without_count

      links = { self: request.url }

      pagination_link_params(representations).each do |rel,link_params|
        link = api_resource_representations_url(resource.identifier,page: link_params)
        links[rel] = link
      end

      apply_link_headers(links)

      render({
        jsonapi: representations.to_a,
        include: %i[resource],
        links: links
      })
    end

    api :GET, '/representations/:id', 'Return attributes of a particular representation'
    def show
      representation = current_user.organization_representations.find(params[:id])

      links = { self: request.url }

      apply_link_headers(links)

      render({
        jsonapi: representation,
        include: %i[resource],
        links: links
      })
    end
  end
end
