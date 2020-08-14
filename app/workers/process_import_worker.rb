# frozen_string_literal: true

class ProcessImportWorker
  include Cloudtasker::Worker

  def perform(id)
    import = Import.find(id)

    resources = []
    import.each_column do |column, name, data|
      mapping = import.column_mapping[name]&.with_indifferent_access
      next unless mapping.present? && mapping[:map_to_column].present?
      raise data.inspect
    end
  end
end
