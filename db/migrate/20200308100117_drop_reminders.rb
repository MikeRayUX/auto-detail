class DropReminders < ActiveRecord::Migration[5.2]
	def change
		drop_table :reminders
  end
end
