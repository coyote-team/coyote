class AddWebhookTokenToResourceGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :resource_groups, :token, :string
    ResourceGroup.all.each do |resource_group|
      resource_group.send(:set_token)
      resource_group.save(validate: false)
    end
  end
end
