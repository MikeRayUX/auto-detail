class AddSubscriptionActiveToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_active, :boolean, default: false
  end
end
