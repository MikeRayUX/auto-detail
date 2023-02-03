class RemoveFinalWeightFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :final_weight
  end
end
