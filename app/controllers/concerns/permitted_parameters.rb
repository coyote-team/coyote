# frozen_string_literal: true

# Defines common parameter handling behavior among controllers
# @see http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
module PermittedParameters
  REPRESENTATION_FILTERS = (%i[
    author_id_eq
    scope
    text_or_resource_canonical_id_or_resource_name_cont_all
    updated_at_gt
  ] + [
    {
      metum_id_in: [],
      scope:       [],
      status_in:   [],
    },
  ]).freeze

  REPRESENTATION_PARAMS = %i[
    author_id
    content_type
    content_uri
    language
    license
    license_id
    metum
    metum_id
    notes
    ordinality
    status
    text
  ].freeze

  RESOURCE_FILTERS = (%i[
    assignments_user_id_eq
    canonical_id_or_name_or_representations_text_cont_all
    priority_flag_eq
    representations_author_id_eq
    representations_updated_at_gt
    scope
    source_uri_eq_any
    updated_at_gt
  ] + [{
    scope: [],
  }]).freeze

  RESOURCE_PARAMS = (
    %i[
      canonical_id
      host_uris
      name
      priority_flag
      resource_group_id
      resource_group_ids
      resource_type
      source_uri
      uploaded_resource
    ] + [{
      representations:    REPRESENTATION_PARAMS,
      resource_group_ids: [],
    }]).freeze

  private

  def clean_resource_params(resource_params)
    resource_params.permit(*RESOURCE_PARAMS).tap do |params|
      representations = params.delete(:representations)
      if representations.present?
        params[:representations_attributes] = representations.map { |representation|
          representation[:author_id] ||= current_user.id
          representation
        }
      end
    end
  end

  def pagination_params
    params.fetch(:page, params).permit(:number, :per_page, :size)
  end

  def representation_params
    params.require(:representation).permit(*REPRESENTATION_PARAMS)
  end

  def resource_params
    clean_resource_params(params.require(:resource))
  end
end
