class RemoveBleachFromOrders < ActiveRecord::Migration[5.2]
	def change
		remove_column :orders, :bleach
  end
end