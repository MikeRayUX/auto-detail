# frozen_string_literal: true

class AddPartnerIdToOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :partner_address
    remove_column :orders, :partner_lat
    remove_column :orders, :partner_long

    add_column :orders, :partner_location_id, :integer
    add_index :orders, :partner_location_id
  end
end
