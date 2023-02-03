class AddPickupTypeToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :pickup_type, :integer
  end
end
