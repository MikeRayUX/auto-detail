class ChangeBagPriceOfNewOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :new_orders, :bag_price
    add_column :new_orders, :bag_price, :decimal, precision: 12, scale: 2
  end
end
