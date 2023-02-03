# frozen_string_literal: true

class AddReminderSentAtToAppointments < ActiveRecord::Migration[5.2]
  def change
    add_column :appointments, :reminder_sent_at, :datetime
  end
end
