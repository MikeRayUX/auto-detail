class AddHasEquipmentToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :has_equipment, :boolean
  end
end
