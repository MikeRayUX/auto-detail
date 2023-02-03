class AddPricePerBagToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :price_per_bag, :decimal, precision: 12, scale: 2
  end
end
