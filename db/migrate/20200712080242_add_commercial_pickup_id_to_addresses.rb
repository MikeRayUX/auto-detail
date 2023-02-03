class AddCommercialPickupIdToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :commercial_pickups, :address_id, :bigint

    add_index :commercial_pickups, :address_id
  end
end
