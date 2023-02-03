# frozen_string_literal: true

class ChangeFinalWeightTypeInOrders < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :final_weight, :float
  end
end
