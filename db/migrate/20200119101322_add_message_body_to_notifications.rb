class AddMessageBodyToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :message_body, :string
  end
end
