# Defines common behavior between the ResourceController and Api::ResourceController
module ResourceAccess
  extend ActiveSupport::Concern
  
  included do
    helper_method :base_resource_query, :resources
  end

  private

  def base_resource_query
    current_user.
      resources.
      ransack(filter_params)
  end

  def resources
    base_resource_query.
      result(distinct: true).
      page(pagination_number).
      per(pagination_size).
      without_count
  end

  def resource_params
    params.require(:resource).permit(:identifier,:title,:resource_type,:canonical_id,:source_uri,:context_id)
  end

  def authorize_general_access
    authorize Resource
  end

  def authorize_unit_access
    authorize(resource)
  end
end
