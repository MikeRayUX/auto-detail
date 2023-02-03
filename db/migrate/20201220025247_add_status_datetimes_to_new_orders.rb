class AddStatusDatetimesToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :enroute_for_pickup_at, :datetime
    add_column :new_orders, :arrived_for_pickup_at, :datetime
    add_column :new_orders, :enroute_for_delivery_at, :datetime
  end
end
