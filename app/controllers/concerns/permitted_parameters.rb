# frozen_string_literal: true

# Defines common parameter handling behavior among controllers
# @see http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
module PermittedParameters
  private

  def pagination_params
    params.fetch(:page, params).permit(:number, :per_page, :size)
  end

  def representation_params
    params.require(:representation).permit(:content_uri, :text, :metum_id, :content_type, :language, :license_id, :notes, :status, :author_id, :endpoint_id, :ordinality)
  end

  def resource_params
    params.require(:resource).permit(
      :canonical_id,
      :host_uris,
      :identifier,
      :ordinality,
      :priority_flag,
      :resource_group_id,
      :resource_type,
      :source_uri,
      :title,
      :uploaded_resource,
    ).tap do |resource_params|
      resource_params[:title] = Resource::DEFAULT_TITLE if resource_params[:title].blank?
    end
  end
end
