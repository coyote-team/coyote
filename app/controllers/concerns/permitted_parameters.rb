# Defines common parameter handling behavior among controllers
# @see http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
module PermittedParameters
  private

  def pagination_params
    params.permit(:number, :per_page, :size)
  end

  def representation_params
    params.require(:representation).permit(:content_uri, :text, :metum_id, :content_type, :language, :license_id, :notes, :status, :author_id, :endpoint_id)
  end

  def resource_params
    params.require(:resource).permit(:identifier, :title, :resource_type, :canonical_id, :source_uri, :resource_group_id, :priority_flag, :host_uris)
  end
end
