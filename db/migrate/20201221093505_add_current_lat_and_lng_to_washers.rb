class AddCurrentLatAndLngToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :current_lat, :float
    add_column :washers, :current_lng, :float
  end
end
