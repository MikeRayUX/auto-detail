class AddWasherFinalPayToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :washer_final_pay, :decimal, precision: 12, scale: 2
    add_column :new_orders, :washer_ppb, :decimal, precision: 12, scale: 2
  end
end
