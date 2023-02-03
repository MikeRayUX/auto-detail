# frozen_string_literal: true

class RenameWeightInOrders < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :weight, :final_weight
    add_column :orders, :partner_reported_weight, :decimal, precision: 12, scale: 2
  end
end
