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
    rejection_reason
    status
    text
  ].freeze

  RESOURCE_FILTERS = (%i[
    assignments_user_id_eq
    canonical_id_or_name_or_representations_text_cont_all
    is_deleted_eq
    priority_flag_eq
    representations_author_id_eq
    representations_updated_at_gt
    resource_group_resources_resource_group_id_in
    s
    scope
    source_uri_eq_any
    updated_at_gt
  ] + [{
    s:     {},
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
      union_host_uris
      union_resource_groups
      uploaded_resource
      organization_id
    ] + [{
      host_uris:          [],
      representations:    REPRESENTATION_PARAMS,
      resource_group_ids: []
    }]).freeze

  private

  def clean_representation_params(representation_params)
    representation_params.permit(*REPRESENTATION_PARAMS).tap do |params|
      params[:author_id] ||= current_user.id
    end
  end

  def clean_resource_params(resource_params, org_id)
    resource_params = ActionController::Parameters.new(resource_params) unless resource_params.respond_to?(:permit)
    resource_params[:organization_id] = org_id
    resource_params.permit(*RESOURCE_PARAMS).tap do |params|
      representations = params.delete(:representations)
      if representations.present?
        params[:overwrite_representations] = overwrite_representations?
        params[:representations_attributes] = representations.map { |representation_params| clean_representation_params(representation_params) }
      end
    end
  end

  def overwrite_representations?
    overwrite_representations = params[:overwrite_representations].present?
    overwrite_representations &&= overwrite_representations.to_s.downcase =~ /^t/
    !!overwrite_representations
  end

  def pagination_params
    params.fetch(:page, params).permit(:number, :per_page, :size)
  end

  def representation_params
    clean_representation_params(params.require(:representation))
  end

  def resource_params(org_id)
    clean_resource_params(params.require(:resource), org_id)
  end
end
