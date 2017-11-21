class AddEndpointIdToRepresentations < ActiveRecord::Migration[5.1]
  def change
    add_reference :representations, :endpoint, foreign_key: { :on_delete => :cascade }, index: true

    e = Endpoint.find_or_create_by!(name: 'All')
    Representation.update_all(endpoint_id: e.id)

    change_column_null :representations, :endpoint_id, false
  end
end
