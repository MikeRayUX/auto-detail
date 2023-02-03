class AddSmsEnabledToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sms_enabled, :boolean, default: true
  end
end
