# frozen_string_literal: true

class AddDeliverToCustomerStatusToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :deliver_to_customer_status, :integer, default: 0
  end
end
