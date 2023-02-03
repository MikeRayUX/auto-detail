# frozen_string_literal: true

class RemoveEstimatedWeightFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :estimated_weight
  end
end
