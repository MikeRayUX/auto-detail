class AddWasherPayPercentageToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :washer_pay_percentage, :float
  end
end
