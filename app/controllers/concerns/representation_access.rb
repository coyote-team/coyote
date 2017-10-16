# Defines common behavior between the RepresentationController and Api::RepresentationController
module RepresentationAccess
  extend ActiveSupport::Concern
  
  private

  def representations
    current_organization.
      representations.
      ransack(params[:q]).
      result.
      page(pagination_number).
      per(pagination_size).
      without_count
  end

  def representation_params
    params.require(:representation).permit(:content_uri,:text,:metum_id,:content_type,:language,:license_id)
  end

  def authorize_general_access
    authorize Representation
  end

  def authorize_unit_access
    authorize(representation)
  end
end
