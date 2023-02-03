# frozen_string_literal: true

class AddClientToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :client_id, :integer, index: true
  end
end
