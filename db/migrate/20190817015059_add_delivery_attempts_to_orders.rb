# frozen_string_literal: true

class AddDeliveryAttemptsToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :delivery_attempts, :integer, default: 0
  end
end
