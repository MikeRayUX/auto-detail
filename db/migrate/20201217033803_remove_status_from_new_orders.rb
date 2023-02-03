class RemoveStatusFromNewOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :new_orders, :status
  end
end
