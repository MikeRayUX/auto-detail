class AddRegionIdToAddresses < ActiveRecord::Migration[5.2]
	def change
		add_column :addresses, :region_id, :bigint
		add_index :addresses, :region_id
  end
end
