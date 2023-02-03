class AddWasherPayToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :washer_pay, :decimal, precision: 12, scale: 2
  end
end
