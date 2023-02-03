class RemoveSubscriptionIdFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :subscription_id
  end
end
