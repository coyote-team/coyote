# Allows bulk changes of Representation statuses from the Representation index page
# @see RepresentationsController
class RepresentationStatusChangesController < ApplicationController
  def create
    status, representation_ids = representation_status_change_params.values_at(:status,:representation_ids)

    representation_ids = Array(representation_ids)

    representations = current_organization.representations.where(id: representation_ids)
    representations.each { |r| authorize(r) }

    representations.update_all(status: status)

    logger.info "Update Representation IDs #{representation_ids.to_sentence} to status '#{status}'"
    flash[:notice] = "Set #{representations.count} #{'representation'.pluralize(representations.count)} to status '#{status.titleize}'"

    redirect_back fallback_location: root_url
  end

  private

  def representation_status_change_params
    params.require(:representation_status_change).permit(:status,:representation_ids => [])
  end
end
