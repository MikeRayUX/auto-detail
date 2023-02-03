class AddCommercialPickupToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :commercial_pickup, :boolean, default: false
  end
end
