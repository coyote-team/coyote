# Allows bulk changes of Representation statuses from the Representation index page
# @see RepresentationsController
class RepresentationStatusChangesController < ApplicationController
  def create
    status, representation_ids = representation_status_change_params.values_at(:status,:representation_ids)

    update_count = if status.present?
                     representation_ids = Array(representation_ids)

                     representations = current_organization.representations.where(id: representation_ids)
                     representations.each { |r| authorize(r) }

                     representations.update_all(status: status)
                     logger.info "Update Representation IDs #{representation_ids.to_sentence} to status '#{status}'"
                   else
                     logger.warn 'Did not update any representations since status was blank'
                     0
                   end

    redirect_back fallback_location: root_url, notice: "Set #{update_count} #{'description'.pluralize(update_count)} to status '#{status.titleize}'"
  end

  private

  def representation_status_change_params
    params.require(:representation_status_change).permit(:status,:representation_ids => [])
  end
end
