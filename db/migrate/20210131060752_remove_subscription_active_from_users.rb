class RemoveSubscriptionActiveFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :subscription_active
  end
end
