# frozen_string_literal: true

class ChangeCourierWeightOnOrdersToFloat < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :courier_weight, :float
  end
end
