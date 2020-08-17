# frozen_string_literal: true

# == Schema Information
#
# Table name: imports
#
#  id              :bigint           not null, primary key
#  error           :string
#  failures        :integer          default(0), not null
#  sheet_mappings  :json
#  status          :integer          default("parsing"), not null
#  successes       :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint
#  user_id         :bigint
#
# Indexes
#
#  index_imports_on_organization_id  (organization_id)
#  index_imports_on_user_id          (user_id)
#
class Import < ApplicationRecord
  REPRESENTATION_IMPORT_COLUMNS = [
    ["Author Name", :author],
  ].freeze

  RESOURCE_GROUP_IMPORT_COLUMNS = [
    ["Resource Group", :name],
    ["Webhook URI", :webhook_uri],
  ].freeze

  RESOURCE_IMPORT_COLUMNS = [
    ["Name", :name],
    ["Canonical ID", :canonical_id],
    ["Source URI", :source_uri],
    ["Priority Flag", :priority_flag],
    ["Host URI(s)", :host_uris],
  ].freeze

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

  after_create_commit :schedule_parse
  after_update_commit :schedule_processing, if: :updated_with_clean_import_mapping?

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
    spreadsheet.open { |file| Roo::Spreadsheet.open(file) }
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
  end

  class Sheet < OpenStruct; end
end
