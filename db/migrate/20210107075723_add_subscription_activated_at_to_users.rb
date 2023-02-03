class AddSubscriptionActivatedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_activated_at, :datetime
  end
end
