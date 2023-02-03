class AddWasherCapacityToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :washer_capacity, :integer, default: 0
  end
end
