# frozen_string_literal: true

desc "Intelligently infers the ordinality of representations to remove duplicates"
task normalize_representation_ordinality: :environment do
  Resource.in_batches.each_record do |resource|
    resource.representations.by_status_and_ordinality.by_creation.each.with_index(1) do |representation, index|
      representation.update_column :ordinality, index
    end
  end
end
