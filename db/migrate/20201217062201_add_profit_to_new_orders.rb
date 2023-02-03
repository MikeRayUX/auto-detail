class AddProfitToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :profit, :decimal, precision: 12, scale: 2
  end
end
