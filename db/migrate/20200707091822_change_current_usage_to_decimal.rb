class ChangeCurrentUsageToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :clients, :current_usage, :decimal, precision: 12, scale: 2
  end
end
