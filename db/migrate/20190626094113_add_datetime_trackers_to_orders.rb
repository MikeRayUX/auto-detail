# frozen_string_literal: true

class AddDatetimeTrackersToOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :picked_up_at
    remove_column :orders, :dropped_off_at

    add_column :orders, :picked_up_from_customer_at, :datetime
    add_column :orders, :received_by_partner_at, :datetime
    add_column :orders, :picked_up_from_partner_at, :datetime
    add_column :orders, :delivered_to_customer_at, :datetime
  end
end
