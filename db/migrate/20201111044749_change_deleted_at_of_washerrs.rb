class ChangeDeletedAtOfWasherrs < ActiveRecord::Migration[5.2]
  def change
    remove_column :washers, :deleted_at
    add_column :washers, :deactivated_at, :datetime
    add_column :washers, :initial_activated_at, :datetime
  end
end
