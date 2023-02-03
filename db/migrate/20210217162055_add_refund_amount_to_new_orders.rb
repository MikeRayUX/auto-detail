class AddRefundAmountToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :refunded_amount, :decimal, precision: 12, scale: 2
  end
end
