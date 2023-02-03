class AddPickupDirectionsToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :pick_up_directions, :string
  end
end
