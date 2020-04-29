class AddWebhookUriToResourceGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :resource_groups, :webhook_uri, :string
  end
end
