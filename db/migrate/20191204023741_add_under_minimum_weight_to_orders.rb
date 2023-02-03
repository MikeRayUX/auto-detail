class AddUnderMinimumWeightToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :under_minimum_weight, :boolean, default: false
  end
end
