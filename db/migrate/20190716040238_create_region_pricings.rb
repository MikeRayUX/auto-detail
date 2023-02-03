# frozen_string_literal: true

class CreateRegionPricings < ActiveRecord::Migration[5.2]
  def change
    create_table :region_pricings do |t|
      t.string :region
      t.float :price_per_pound
      t.float :deposit_cost

      t.timestamps
    end
  end
end
