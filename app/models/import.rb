# frozen_string_literal: true

# == Schema Information
#
# Table name: imports
#
#  id                :bigint           not null, primary key
#  changed_records   :integer          default(0), not null
#  duplicate_records :integer          default(0), not null
#  error             :string
#  failures          :integer          default(0), not null
#  new_records       :integer          default(0), not null
#  sheet_mappings    :json
#  status            :integer          default("parsing"), not null
#  successes         :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_imports_on_organization_id  (organization_id)
#  index_imports_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
class Import < ApplicationRecord
  METUM_IMPORT_COLUMNS = [
    ["Add a new description type", :new],
  ]

  REPRESENTATION_IMPORT_COLUMNS = [
    ["Author name", :author],
    ["Status", :status],
  ].freeze

  RESOURCE_GROUP_IMPORT_COLUMNS = [
    ["Group", :name],
    ["Webhook URI", :webhook_uri],
  ].freeze

  RESOURCE_IMPORT_COLUMNS = [
    ["Name", :name],
    ["Canonical ID", :canonical_id],
    ["Source URI", :source_uri],
    ["Priority flag", :priority_flag],
    ["Host URI(s)", :host_uris],
  ].freeze

  # For reasons which are unclear, this has to be added before associations in order for upload
  # callbacks to fire in the right order. Whatever.
  after_create_commit :schedule_parse
  after_update_commit :schedule_processing, if: :updated_with_clean_import_mapping?

  belongs_to :organization
  belongs_to :user
  has_one_attached :spreadsheet

  enum status: {
    parsing:       0,
    parse_failed:  1,
    parsed:        2,
    importing:     3,
    import_failed: 4,
    imported:      5,
  }

  validates :spreadsheet, presence: true, on: :create
  validate :can_create_resources, if: :changed_to_importing?

  def cannot_edit_message
    return nil if editable?
    explanation = I18n.t("import.cannot_edit.#{status}")
    I18n.t("import.cannot_edit.base", explanation: explanation)
  end

  def editable?
    parsed? || import_failed? || imported?
  end

  def name
    "#{default_name}: #{spreadsheet.filename}"
  end

  # Creates a standard interface to a spreadsheet while reading it from the uploaded file - only used in workers
  def read_sheets
    workbook = open_spreadsheet
    [].tap do |sheets|
      workbook.each_with_pagename do |sheet_name, sheet|
        rows = sheet.parse(clean: true, headers: true)
        headers = rows.shift.keys
        sheets.push(
          Sheet.new(
            name:    sheet_name,
            columns: map_columns(Array((sheet_mappings || {})[sheet_name]), sheet_name),
            headers: headers,
            rows:    rows,
          ),
        )
      end
    end
  end

  def sheet_mappings=(new_sheet_mappings)
    if parsed? || importing?
      new_sheet_mappings = (new_sheet_mappings || {}).with_indifferent_access
      super (sheet_mappings || {}).with_indifferent_access.deep_merge(new_sheet_mappings)
    else
      super
    end
  end

  # Creates a standard interface to a spreadsheet based on parsed values stored on the model - only used for mapping spreadsheet columns to Coyote columns
  def sheets
    return @sheets if defined? @sheets
    @sheets = sheet_mappings.map { |sheet_name, columns|
      Sheet.new(
        name:    sheet_name,
        headers: columns.keys,
        columns: map_columns(columns, sheet_name),
      )
    }
  end

  def type
    spreadsheet
  end

  private

  def can_create_resources
    errors.add(:base, :needs_source_uri_mapping) unless can_create_resources?
  end

  def can_create_resources?
    return @can_create_resources if defined? @can_create_resources
    @can_create_resources = sheets.any? { |sheet| sheet.columns.any? { |column| column.map_to_column == "Resource:source_uri" } }
  end

  def changed_to_importing?
    importing? && status_changed?
  end

  def map_columns(columns_hash, sheet_name)
    columns_hash.map { |column_name, options|
      Column.new(options.merge(name: column_name, sheet_name: sheet_name))
    }
  end

  def open_spreadsheet
    spreadsheet.open { |file|
      # Copy the file to a tempfile so it can be embedded - ActiveStorage will remove ITS tempfile
      # after we read it, which will screw ... just EVERYTHING up. So we make a copy for Roo to
      # use, because CSVs are not loaded into memory until access time - meaning this block will
      # have closed and the file will be wiped
      path = file.path
      tmp_path = File.join(Dir.tmpdir, "#{SecureRandom.hex(10)}.#{File.extname(path)}")
      FileUtils.copy(path, tmp_path)
      Roo::Spreadsheet.open(tmp_path)
    }
  end

  def schedule_parse
    ParseImportSpreadsheetWorker.perform_async(id)
  end

  def schedule_processing
    ProcessImportWorker.perform_async(id)
  end

  def updated_with_clean_import_mapping?
    importing? && previous_changes.include?(:status) && can_create_resources?
  end

  class Column < OpenStruct
    def form_name
      "import[sheet_mappings][#{sheet_name}][#{name}][map_to_column]"
    end

    def hint
      "Example values: #{examples}"
    end

    def id
      @id ||= "import_columns_#{sheet_name}_#{name}".parameterize
    end
  end

  class Sheet < OpenStruct; end
end
