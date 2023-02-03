class AddMoreAddressFieldsToNewOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :full_address, :string
    add_column :new_orders, :address_lat, :float
    add_column :new_orders, :address_lng, :float
  end
end
