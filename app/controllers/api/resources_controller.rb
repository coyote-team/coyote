# rubocop:disable Metrics/ClassLength
module Api
  # Handles calls to /api/v1/resources/
  class ResourcesController < Api::ApplicationController
    include PermittedParameters

    before_action :find_resource,            only: %i[show update destroy]
    before_action :authorize_general_access, only: %i[index create]
    before_action :authorize_unit_access,    only: %i[show update destroy]

    resource_description do
      short 'Anything with an identity that can be represented in the Coyote database'

      desc <<~DESC
        We use the Dublin Core meaning for what a Resource represents: "...a resource is anything that has identity. Familiar examples include an electronic document, an image,
        a service (e.g., "today's weather report for Los Angeles"), and a collection of other resources. Not all resources are network "retrievable"; e.g., human beings,
        corporations, and bound books in a library can also be considered resources."
      DESC

      formats %w[json]
    end

    def_param_group :resource do
      param :resource, Hash, action_aware: true do
        param :id,              Integer, 'Resource ID', required: true
        param :identifier,      String,  'Unique human-readable identifier (slug) for this resource', required: true
        param :title,           String,  'Caption that helps humans identify the resource', required: false
        param :resource_type,   String,  'Dublin Core Metadata type for this resource', required: true
        param :canonical_id,    String,  'Unique identifier assigned by the organization that owns this resource', required: true
        param :source_uri,      String,  'The canonical location of the resource', required: false
        param :resource_group,  String,  'Identifies the organizationl resource_group to which this resource belongs', required: true
        param :organization_id, Integer, 'Identifies which organization owns the resource', required: true
      end
    end

    api :GET, 'resources', 'Return a list of resources available to the authenticated user'
    param_group :pagination, Api::ApplicationController
    param :filter, Hash do
      param :identifier_or_title_or_representations_text_cont_all, String, 'Search Resource identifier, title, or associated Representation text for this value'
      param :updated_at_gt, Date, 'Filter returned resources to those whose `updated_at` value is after the given date'
      param :scope, Resource.ransackable_scopes.to_a, 'Limit search to Resources in these states'
    end
    example <<~EXAMPLE
    curl  -H 'Authorization: CHANGEME' http://localhost:10000/api/v1/organizations/1/resources/ | jsonlint
      {
    "data": [
      {
        "id": "t.y.f.f.s.h.,_2011_929d",
        "type": "resource",
        "attributes": {
          "title": "T.Y.F.F.S.H., 2011",
          "resource_type": "still_image",
          "canonical_id": "c4ca4238a0b923820dcc509a6f75849b",
          "source_uri": "https://coyote.pics/wp-content/uploads/2016/02/Screen-Shot-2016-02-29-at-10.05.14-AM-1024x683.png",
          "created_at": "2017-11-06T16:17:49.630Z",
          "updated_at": "2017-11-06T16:55:10.207Z",
          "resource_group": "collection"
        },
        "relationships": {
          "organization": {
            "data": {
              "type": "organization",
              "id": "1"
            }
          },
          "representations": {
            "data": [
              {
                "type": "representation",
                "id": "1"
              }
            ]
          }
        }
      },
      {
        "id": "mona_lisa_48f9",
        "type": "resource",
        "attributes": {
          "title": "Mona Lisa",
          "resource_type": "still_image",
          "canonical_id": "c81e728d9d4c2f636f067f89cc14862c",
          "source_uri": "http://example.com/image123.png",
          "created_at": "2017-11-06T16:17:49.926Z",
          "updated_at": "2017-11-06T16:17:49.926Z",
          "resource_group": "voluptatibus"
        },
        "relationships": {
          "organization": {
            "data": {
              "type": "organization",
              "id": "1"
            }
          },
          "representations": {
            "data": []
          }
        }
      }
    ],
    "included": [
      {
        "id": "1",
        "type": "organization",
        "attributes": {
          "title": "Acme Museum"
        }
      },
      {
        "id": "1",
        "type": "representation",
        "attributes": {
          "status": "approved",
          "content_uri": null,
          "content_type": "text/plain",
          "language": "en",
          "text": "A red, white, and blue fabric canopy presses against walls of room; portable fans blow air into the room through a doorway.",
          "created_at": "2017-11-06T16:17:49.811Z",
          "updated_at": "2017-11-06T16:19:23.998Z",
          "metum": "Short",
          "author": "effie.boyle@carroll.org",
          "license": "Et quo dignissimos ex. Non optio minima eum qui. Placeat adipisci id omnis amet rem pariatur."
        },
        "relationships": {
          "resource": {
            "meta": {
              "included": false
            }
          }
        },
        "links": {
          "self": null
        }
      }
    ],
    "links": {
      "self": "http://localhost:10000/api/v1/organizations/1/resources",
      "first": "http://localhost:10000/api/v1/organizations/1/resources?page%5Bnumber%5D=1\\u0026page%5Bsize%5D=50"
    },
    "jsonapi": {
      "version": "1.0"
    }
    TEST
    EXAMPLE
    def index
      links = { self: request.url }

      resources = record_filter.records

      record_filter.pagination_link_params.each do |rel, link_params|
        link = api_resources_url(link_params)
        links[rel] = link
      end

      render({
        jsonapi: resources.to_a,
        include: %i[organization representations],
        links: links
      })
    end

    api :GET, 'resources/:id', 'Return attributes of a particular resource'
    example <<~EXAMPLE
    curl  -H 'Authorization: CHANGEME' http://localhost:10000/api/v1/resources/1 | jsonlint
    {
      "data": {
        "id": "t.y.f.f.s.h.,_2011_929d",
        "type": "resource",
        "attributes": {
          "id": "t.y.f.f.s.h.,_2011_929d",
          "title": "T.Y.F.F.S.H., 2011",
          "resource_type": "still_image",
          "canonical_id": "c4ca4238a0b923820dcc509a6f75849b",
          "source_uri": "https://coyote.pics/wp-content/uploads/2016/02/Screen-Shot-2016-02-29-at-10.05.14-AM-1024x683.png",
          "created_at": "2017-11-06T16:17:49.630Z",
          "updated_at": "2017-11-06T16:55:10.207Z",
          "resource_group": "collection"
        },
        "relationships": {
          "organization": {
            "data": {
              "type": "organization",
              "id": "1"
            }
          },
          "representations": {
            "data": [
              {
                "type": "representation",
                "id": "1"
              }
            ]
          }
        }
      },
      "included": [
        {
          "id": "1",
          "type": "organization",
          "attributes": {
            "title": "Acme Museum"
          }
        },
        {
          "id": "1",
          "type": "representation",
          "attributes": {
            "status": "approved",
            "content_uri": null,
            "content_type": "text/plain",
            "language": "en",
            "text": "A red, white, and blue fabric canopy presses against walls of room; portable fans blow air into the room through a doorway.",
            "created_at": "2017-11-06T16:17:49.811Z",
            "updated_at": "2017-11-06T16:19:23.998Z",
            "metum": "Short",
            "author": "effie.boyle@carroll.org",
            "license": "Et quo dignissimos ex. Non optio minima eum qui. Placeat adipisci id omnis amet rem pariatur."
          },
          "relationships": {
            "resource": {
              "meta": {
                "included": false
              }
            }
          },
          "links": {
            "self": null
          }
        }
      ],
      "jsonapi": {
        "version": "1.0"
      }
    }
    EXAMPLE
    def show
      render({
        jsonapi: resource,
        include: %i[organization representations]
      })
    end

    api :POST, 'resources', 'Create a new resource'
    param_group :resource
    def create
      resource_group_id = resource_params.delete(:resource_group_id)
      resource_group = current_user.resource_groups.find(resource_group_id)

      resource = current_organization.resources.new(resource_params)
      resource.resource_group = resource_group

      if resource.save
        logger.info "Created #{resource}"
        render jsonapi: resource, status: :created
      else
        logger.warn "Unable to create resource due to '#{resource.error_sentence}'"
        render jsonapi_errors: resource.errors, status: :unprocessable_entity
      end
    end

    api :PATCH, 'resources/:id', 'Update attributes of a particular resource'
    def update
      if resource.update_attributes(resource_params)
        logger.info "Updated #{resource}"
        render jsonapi: resource
      else
        logger.warn "Unable to update resource due to '#{resource.error_sentence}'"
        render jsonapi_errors: resource.errors, status: :unprocessable_entity
      end
    end

    private

    attr_accessor :resource
    attr_writer :current_organization

    def authorize_general_access
      authorize(Resource)
    end

    def authorize_unit_access
      authorize(resource)
    end

    def record_filter
      @record_filter ||= RecordFilter.new(filter_params, pagination_params, current_user.resources)
    end

    def filter_params
      params.fetch(:filter, {}).permit(:identifier_or_title_or_representations_text_cont_all, :updated_at_gt, scope: [])
    end
  end
end
