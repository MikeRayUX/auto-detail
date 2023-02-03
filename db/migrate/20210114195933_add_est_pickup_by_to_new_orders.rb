class AddEstPickupByToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :est_pickup_by, :datetime
  end
end
