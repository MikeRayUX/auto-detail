# frozen_string_literal: true

class AddAddressToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :customer_address, :string
    add_column :orders, :customer_lat, :float
    add_column :orders, :customer_long, :float

    add_column :orders, :partner_address, :string
    add_column :orders, :partner_lat, :float
    add_column :orders, :partner_long, :float
  end
end
