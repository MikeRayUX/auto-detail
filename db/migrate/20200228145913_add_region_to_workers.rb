class AddRegionToWorkers < ActiveRecord::Migration[5.2]
	def change
		add_column :workers, :region_id, :bigint
		add_index :workers, :region_id
  end
end
