# frozen_string_literal: true

class ParseImportSpreadsheetWorker
  include Cloudtasker::Worker

  def perform(id)
    import = Import.find(id)

    columns = {}
    import.each_column do |column, name, rows|
      examples = rows.map { |row| row[column] }.uniq.first(3).to_sentence
      columns[name] = {
        examples:      examples,
        map_to_column: nil,
      }
    end

    import.update!(column_mapping: columns, status: :parsed)
  end
end
