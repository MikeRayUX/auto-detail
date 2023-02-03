class RemoveEnrouteForDeliveryAtFromNewOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :new_orders, :enroute_for_delivery_at
  end
end
