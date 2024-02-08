# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :find_import, only: %i[edit show update]
  before_action :authorize_access
  before_action :require_editable_import, only: %i[edit update]

  helper_method :import, :imports

  def create
    self.import = current_organization.imports.new(import_params.merge(user: current_user))
    if is_text_file?
      import.save!
      redirect_to import_path(import), success: "Your import file has been uploaded"
    else
      flash[:alert] = "Please Upload a properly formatted csv file."
      render :new
    end
  end

  def edit
  end

  def index
    self.imports = current_organization.imports
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

  attr_accessor :import, :imports

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
    unless import.editable?
      redirect_to import_path, alert: import.cannot_edit_message
    end
  end

  def update_import_params
    params.require(:import).permit(
      :status,
      sheet_mappings: {},
    )
  end

  def is_text_file?
    file = params[:import][:spreadsheet].tempfile
    check(file)
  end

  def check(file)
    non_ascii_printable = /[^\x20-\x7e\s]/

    open(file) do |f|
      if nonbinary?(f, non_ascii_printable)
        # puts "#{file}: ascii printable"
        return true
      else
        # puts "#{file}: binary"
        false
      end
    end
  end

  def nonbinary?(io, forbidden, size = 1024)
    while buf = io.read(size)
      return false if forbidden =~ buf
    end

    true
  end
end
