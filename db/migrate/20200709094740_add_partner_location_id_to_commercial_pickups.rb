class AddPartnerLocationIdToCommercialPickups < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :commercial_pickup

    add_column :commercial_pickups, :partner_location_id, :bigint
    add_index :commercial_pickups, :partner_location_id
  end
end
