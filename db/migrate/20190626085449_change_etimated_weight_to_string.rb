# frozen_string_literal: true

class ChangeEtimatedWeightToString < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :estimated_weight, :string
  end
end
