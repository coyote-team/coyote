class CitextEverything < ActiveRecord::Migration[6.0]
  def change
    {
      invitations: %i[recipient_email token],
      licenses: %i[name url],
      meta: %i[name],
      organizations: %i[name],
      representations: %i[content_uri language],
      resource_groups: %i[name webhook_uri],
      resource_webhook_calls: %i[uri],
      users: %i[email first_name last_name]
    }.each do |table, columns|
      columns.each do |column|
        change_column table, column, :citext
      end
    end
  end
end
