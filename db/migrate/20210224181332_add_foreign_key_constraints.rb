class AddForeignKeyConstraints < ActiveRecord::Migration[6.0]
  CONSTRAINTS = {
      assignment: %i[user resource],
      auth_token: :user,
      import: %i[organization user],
      invitation: %i[organization sender_user recipient_user],
      membership: %i[organization user],
      metum: :organization,
      organization: :default_license,
      password_reset: :user,
      representation: %i[resource metum author license],
      resource_group_resource: %i[resource_group resource],
      resource_group: :organization,
      resource_link: %i[subject_resource object_resource],
      resource_webhook_call: :resource,
      resource: :organization,
  }.freeze

  def change
    CONSTRAINTS.each do |model_name, associations|
      model = model_name.to_s.classify.constantize
      Array(associations).each do |association_name|
        belongs_to = model.reflect_on_association(association_name)
        description = "#{model.table_name}.#{belongs_to.foreign_key} => #{belongs_to.table_name}.#{belongs_to.association_primary_key}"
        puts "-- #{reverting? ? "Removing" : "Adding"} constraint #{description}..."
        options = [
            model.table_name,
            belongs_to.table_name,
            column: belongs_to.foreign_key,
            primary_key: belongs_to.association_primary_key
        ]
        proceed = reverting? ?  true : !foreign_key_exists?(*options)
        if proceed
          add_foreign_key(*options)
        else
          puts "--   skipping"
        end
      end
    end
  end
end
