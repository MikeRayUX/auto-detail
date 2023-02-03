class AddSubscriptionStartEndToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_expires_at, :datetime
  end
end
