class AddWasherAdjustedBagCountAtToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :washer_adjusted_bag_count_at, :datetime
  end
end
