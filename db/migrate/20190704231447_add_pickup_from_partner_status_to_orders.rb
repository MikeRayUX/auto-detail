# frozen_string_literal: true

class AddPickupFromPartnerStatusToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :pick_up_from_partner_status, :integer, default: 0
  end
end
