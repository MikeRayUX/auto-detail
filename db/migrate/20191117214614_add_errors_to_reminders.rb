class AddErrorsToReminders < ActiveRecord::Migration[5.2]
  def change
    add_column :reminders, :send_errors, :string
  end
end
