# frozen_string_literal: true

class ParseImportSpreadsheetWorker < ApplicationWorker
  def perform(id)
    import = Import.find(id)

    sheets = {}
    import.read_sheets.each do |sheet|
      columns = {}
      sheet.headers.each do |header|
        next if header.blank?
        examples = sheet.rows.map { |row| row[header] }.uniq.reject(&:blank?).first(3).to_sentence
        columns[header] = {
          examples:      examples,
          map_to_column: nil,
        }
      end

      sheets[sheet.name] = columns
    end

    import.update!(sheet_mappings: sheets, status: :parsed)
  rescue => error
    Raven.capture_exception(error)
    import.update(error: error.message, sheet_mappings: {}, status: :parse_failed)
  end
end
