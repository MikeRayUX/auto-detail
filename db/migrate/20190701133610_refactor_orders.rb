# frozen_string_literal: true

class RefactorOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :courier_weight, :decimal, precision: 12, scale: 2
    remove_column :orders, :partner_id
    rename_column :orders, :received_by_partner_at, :dropped_off_to_partner_at
  end
end
