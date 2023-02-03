class AddBusinessHoursToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :business_open, :string
    add_column :regions, :business_close, :string
  end
end
