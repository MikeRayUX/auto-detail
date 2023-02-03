class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :order
      t.references :user
      t.integer :notification_method
      t.integer :event
      t.boolean :sent
      t.datetime :sent_at
      t.string :send_errors

      t.timestamps
    end
  end
end
