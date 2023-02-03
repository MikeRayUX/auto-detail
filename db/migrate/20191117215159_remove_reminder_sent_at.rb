class RemoveReminderSentAt < ActiveRecord::Migration[5.2]
  def change
    remove_column :appointments, :reminder_sent_at
  end
end
