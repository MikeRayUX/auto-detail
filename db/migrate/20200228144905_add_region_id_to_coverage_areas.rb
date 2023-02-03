class AddRegionIdToCoverageAreas < ActiveRecord::Migration[5.2]
	def change
		add_column :coverage_areas, :region_id, :bigint
		add_index :coverage_areas, :region_id
  end
end
