class AddHoursSavedToTransaction < ActiveRecord::Migration[5.2]
	def change
		add_column :transactions, :wash_hours_saved, :float
  end
end
