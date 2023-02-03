# frozen_string_literal: true

class AddWeighteEstimateToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :estimated_weight, :integer
  end
end
