# frozen_string_literal: true

class ParseImportSpreadsheetWorker
  include Cloudtasker::Worker

  def perform(id)
    import = Import.find(id)

    sheets = {}
    import.read_sheets.each do |sheet|
      columns = {}
      sheet.headers.each do |header|
        examples = sheet.rows.map { |row| row[header] }.uniq.first(3).to_sentence
        columns[header] = {
          examples:      examples,
          map_to_column: nil,
        }
      end

      sheets[sheet.name] = columns
    end

    import.update!(sheet_mappings: sheets, status: :parsed)
  end
end
