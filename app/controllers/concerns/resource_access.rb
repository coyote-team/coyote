module ResourceAccess
  extend ActiveSupport::Concern
  
  def index
    self.resources = current_user.
                     resources.
                     by_id.
                     page(pagination_number).
                     per(pagination_size).
                     without_count
  end

  private

  attr_accessor :resources

  def resource_params
    params.require(:resource).permit(:identifier,:title,:resource_type,:canonical_id,:source_uri,:context_id,:priority)
  end

  def authorize_general_access
    authorize Resource
  end

  def authorize_unit_access
    authorize(resource)
  end
end
