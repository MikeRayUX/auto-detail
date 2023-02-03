class AddNewOrderIdToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :new_order_id, :bigint
  end
end
