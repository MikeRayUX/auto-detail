# frozen_string_literal: true

class AddMinimumWeightToRegionPricing < ActiveRecord::Migration[5.2]
  def change
    add_column :region_pricings, :minimum_weight, :integer
    add_column :region_pricings, :minimum_weight_fee, :decimal, precision: 12, scale: 2
  end
end
