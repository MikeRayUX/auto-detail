class AddIndexToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_index :new_orders, :ref_code
  end
end
