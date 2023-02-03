class RemoveCurrentUsageFromClient < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :current_usage
  end
end
