class AddWasherPayPercentToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :washer_pay_percentage, :float
  end
end
