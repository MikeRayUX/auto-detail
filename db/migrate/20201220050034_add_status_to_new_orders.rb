class AddStatusToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :status, :integer, default: 0
  end
end
