class AddRegionIdToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :region_id, :bigint
    add_index :washers, :region_id
  end
end
