# frozen_string_literal: true

# == Schema Information
#
# Table name: imports
#
#  id              :bigint           not null, primary key
#  column_mapping  :json
#  error           :string
#  status          :integer          default("parsing"), not null
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
    ["Name", :name],
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

  after_create_commit :schedule_parse

  def column_mapping=(new_column_mapping)
    if parsed? || importing?
      new_column_mapping = (new_column_mapping || {}).with_indifferent_access
      super (column_mapping || {}).with_indifferent_access.deep_merge(new_column_mapping)
    else
      super
    end
  end

  def columns
    return @columns if defined? @columns
    @columns = column_mapping.map { |name, column|
      Column.new(column.merge(name: name))
    }
  end

  def each_column
    parsed = open_spreadsheet
    many_sheets = parsed.sheets.many?
    parsed.each_with_pagename do |sheet_name, sheet|
      rows = sheet.parse(headers: true)
      headers = rows.shift
      headers.keys.each do |column|
        name = many_sheets ? "#{name}: #{column}" : column
        yield column, name, rows
      end
    end
  end

  def each_row
    parsed = open_spreadsheet
  end

  def editable?
    parsed? || import_failed? || imported?
  end

  def name
    "#{default_name}: #{spreadsheet.filename}"
  end

  def type
    spreadsheet
  end

  private

  def open_spreadsheet
    spreadsheet.open { |file| Roo::Spreadsheet.open(file) }
  end

  def schedule_parse
    ParseImportSpreadsheetWorker.perform_async(id)
  end

  class Column < OpenStruct
    def form_name
      "import[column_mapping][#{name}][map_to_column]"
    end

    def hint
      "Example values: #{examples}"
    end
  end
end
