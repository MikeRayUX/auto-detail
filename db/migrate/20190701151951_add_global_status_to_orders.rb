# frozen_string_literal: true

class AddGlobalStatusToOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :status
    add_column :orders, :global_status, :integer, default: 0
    add_column :orders, :pick_up_from_customer_status, :integer, default: 0
    add_column :orders, :drop_off_to_partner_status, :integer, default: 0
  end
end
