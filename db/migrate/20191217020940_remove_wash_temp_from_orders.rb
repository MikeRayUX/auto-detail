class RemoveWashTempFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :wash_temp
    remove_column :orders, :use_bleach_on_whites
    remove_column :orders, :detergent

    add_column :orders, :detergent, :integer
    add_column :orders, :bleach, :integer
    add_column :orders, :softener, :integer

    remove_column :wash_preferences, :wash_temp
    remove_column :wash_preferences, :use_bleach_on_whites
    
    add_column :wash_preferences, :bleach, :integer
    add_column :wash_preferences, :softener, :integer
  end
end
