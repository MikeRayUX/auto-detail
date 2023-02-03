class RemoveUnderMinimumWeightFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :under_minimum_weight
  end
end
