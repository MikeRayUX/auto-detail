class RemoveMinimumWeightFromRegionPricing < ActiveRecord::Migration[5.2]
  def change
    remove_column :region_pricings, :minimum_weight
    remove_column :region_pricings, :minimum_weight_fee

    add_column :region_pricings, :minimum_charge, :decimal, precision: 12, scale: 2
  end
end
