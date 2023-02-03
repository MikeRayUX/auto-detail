# frozen_string_literal: true

class ChangePriceAndTaxToDecimalOfRegionPricing < ActiveRecord::Migration[5.2]
  def change
    change_column :region_pricings, :price_per_pound, :decimal, precision: 12, scale: 2
    change_column :region_pricings, :deposit_cost, :decimal, precision: 12, scale: 2
  end
end
