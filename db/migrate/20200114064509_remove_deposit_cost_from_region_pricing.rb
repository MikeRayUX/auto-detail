class RemoveDepositCostFromRegionPricing < ActiveRecord::Migration[5.2]
  def change
    remove_column :region_pricings, :deposit_cost
  end
end
