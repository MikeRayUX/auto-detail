# frozen_string_literal: true

class AddTaxrateToRegionpricings < ActiveRecord::Migration[5.2]
  def change
    add_column :region_pricings, :tax_rate, :float
  end
end
