class AddDeliveryLocationToNewOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :new_orders, :delivery_location
    add_column :new_orders, :delivery_location, :integer
  end
end
