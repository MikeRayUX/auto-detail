# frozen_string_literal: true

class AddMarkedAsReadToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :marked_as_ready_for_pickup_from_partner, :boolean, default: false
  end
end
