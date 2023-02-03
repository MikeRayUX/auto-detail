class AddScannedBagsToNewOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :bag_codes, :string
  end
end
