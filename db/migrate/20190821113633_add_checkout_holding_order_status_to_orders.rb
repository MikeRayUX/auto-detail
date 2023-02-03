# frozen_string_literal: true

class AddCheckoutHoldingOrderStatusToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :checkout_holding_order_status, :integer
  end
end
