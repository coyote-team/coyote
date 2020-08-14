# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :find_import, only: %i[edit show update]
  before_action :authorize_access
  before_action :require_editable_import, only: %i[edit update]

  helper_method :import

  def create
    self.import = current_organization.imports.new(import_params.merge(user: current_user))
    import.save!
    redirect_to import_path(import), success: "Your import file has been uploaded"
  end

  def edit
  end

  def new
    self.import = current_user.imports.new
  end

  def show
  end

  def update
    import.update!(update_import_params)
    ProcessImportWorker.perform_async(import.id)
    redirect_to import_path(import)
  end

  private

  attr_accessor :import

  def authorize_access
    authorize(import || Import)
  end

  def find_import
    self.import = current_organization.imports.find(params[:id])
  end

  def import_params
    params.require(:import).permit(:spreadsheet)
  end

  def require_editable_import
    redirect_to import_path, alert: "You cannot edit this import's mappings while it is #{import.status_label}" unless import.editable?
  end

  def update_import_params
    params.require(:import).permit(
      :status,
      column_mapping: {},
    )
  end
end
