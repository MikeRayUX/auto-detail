# frozen_string_literal: true

class CreateReminders < ActiveRecord::Migration[5.2]
  def change
    create_table :reminders do |t|
      t.boolean :sent, default: false
      t.datetime :sent_at
      t.integer :notification_method
      t.belongs_to :appointment
      t.timestamps
    end
  end
end
