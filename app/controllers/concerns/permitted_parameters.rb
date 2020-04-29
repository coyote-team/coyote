# frozen_string_literal: true

# Defines common parameter handling behavior among controllers
# @see http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
module PermittedParameters
  private

  def pagination_params
    params.fetch(:page, params).permit(:number, :per_page, :size)
  end

  def representation_params
    params.require(:representation).permit(
      :author_id,
      :content_type,
      :content_uri,
      :endpoint_id,
      :language,
      :license_id,
      :metum_id,
      :notes,
      :ordinality,
      :status,
      :text,
    )
  end

  def resource_params
    params.require(:resource).permit(
      :canonical_id,
      :host_uris,
      :identifier,
      :ordinality,
      :priority_flag,
      :resource_group_id,
      :resource_group_ids,
      :resource_type,
      :source_uri,
      :title,
      :uploaded_resource,
      resource_group_ids: [],
    )
  end
end
