# frozen_string_literal: true

module TableHelper
  def table_of(parent, relationship, options = {})
    relationship_component(parent, relationship) do |items|
      tag.div(combine_options(options, class: "table-wrapper")) do
        tag.table do
          yield items
        end
      end
    end
  end
end
