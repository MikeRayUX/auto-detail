class AddWorkerIdToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :worker_id, :integer

    add_index :notifications, :worker_id
  end
end
